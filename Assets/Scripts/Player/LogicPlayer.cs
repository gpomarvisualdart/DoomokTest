using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ParticleData;

public class LogicPlayer : MonoBehaviour, IDamageDealer, IEntityKnockback, IGenericAbillityRequests
{
    InputManager inputManager;
    Rigidbody rb;
    EntityCapsulePhysicsController entPhys;
    [SerializeField] PlayerStates currentState;
    IEntityHealthController healthController;
    AnimationComms animComms;

    Vector3 MoveDir;
    float airForce;
    float maxAirSpd = 6f;
    int numOfJumpsMidAir = 1;
    int currentCombo;
    int maxCombos;
    int playerLayer;
    int enemyLayer;

    [SerializeField] Abillity currentAbillity;

    [SerializeField] List<Abillity> basicAttacks = new List<Abillity>();

    [SerializeField] Transform Hitbox;

    [SerializeField] float jumpHeight;

    IHitboxController hitboxController;

    public Transform GetPlayerTransform() { return transform; }

    bool canCombo = false;

    private void OnEnable()
    {
        while (inputManager == null)
        {
            inputManager = FindObjectOfType<InputManager>();
        }
        inputManager.AttackEventSender += AttackEventReceiver;
        inputManager.JumpEventSender += JumpEventReceiver;
        inputManager.DashEventSender += DashEventReceiver;

        canCombo = false;
        maxCombos = basicAttacks.Count < 1 ? 0 : basicAttacks.Count - 1;
        rb = GetComponent<Rigidbody>();
        rb.velocity = Vector3.zero;
        entPhys = TryGetComponent(out EntityCapsulePhysicsController epc) ? epc : null;
        //rb.isKinematic = true;
        airForce = rb.mass * 30f;
        animComms = GetComponentInChildren<AnimationComms>();
        playerLayer = LayerMask.NameToLayer("Player");
        enemyLayer = LayerMask.NameToLayer("Enemies");
        healthController = TryGetComponent(out IEntityHealthController ieh) ? ieh : null;

        hitboxController = Hitbox.TryGetComponent(out IHitboxController hc) ? hc : null;

        animComms.AnimationTriggerEvent += AnimationTriggerEventReceiver;
    }


    private void OnDisable()
    {
        if (inputManager != null)
        {
            inputManager.AttackEventSender -= AttackEventReceiver;
            inputManager.JumpEventSender -= JumpEventReceiver;
            inputManager.DashEventSender -= DashEventReceiver;
        }
    }




    private void JumpEventReceiver(object sender, System.EventArgs e)
    {
        if (CO_OnKnockback != null) return;
        if (numOfJumpsMidAir < 1) return;
        if (CO_Dashing != null && currentState == PlayerStates.Dashing) { currentState = PlayerStates.Idle; StopCoroutine(CO_Dashing); CO_Dashing = null; }
        
        AttackEnds();

        entPhys.collisionLayers = entPhys.defaultcollisionLayers;
        currentState = PlayerStates.Idle;
        animComms.RequestPlayAnimation((int)GenericAnimEnums.IDLE, 1, 0, false, true);
        entPhys.currentGravity = -50f;
        float jumpVel = Mathf.Sqrt(2 * -entPhys.currentGravity * jumpHeight);
        entPhys.currentVelocity.y = jumpVel;
        numOfJumpsMidAir--;

    }

    private void AttackEventReceiver(object sender, System.EventArgs e)
    {
        if (CO_Dashing != null || CO_OnKnockback != null) return;
        if (basicAttacks.Count < 1) return;
        if (currentAbillity != null && canCombo == false) return;
        entPhys.collisionLayers = entPhys.defaultcollisionLayers;
        currentState = PlayerStates.Attacking;
        currentAbillity = basicAttacks[currentCombo];
        currentAbillity.Execute();
    }


    public void AttackEnds()
    {
        currentAbillity = null;
        canCombo = false;
        currentCombo = 0;
        ActivateHitbox(false, 0f, 0f);
        currentState = PlayerStates.Idle;
    }


    public void RequestMovement(Vector3 direction, float spd, float duration, bool isDynamic, Dictionary<MovementAdditionalInfo, int> additionalInfo)
    {
        if (isDynamic)
        {
            
        }
        else
        {
            StaticMovement(direction, spd, additionalInfo);
        }
    }
    private void StaticMovement(Vector3 dir, float spd, Dictionary<MovementAdditionalInfo, int> addInfo)
    {
        //rb.isKinematic = false;
        entPhys.currentVelocity = dir * spd;
    }

    public void RequestJump(Vector3 position, Dictionary<JumpAdditionalInfo, int> additionalData, float duration)
    {
        throw new System.NotImplementedException();
    }

    public void RequestAirSlam(Vector3 position, Dictionary<JumpAdditionalInfo, int> additionalData, float duration)
    {
        throw new System.NotImplementedException();
    }

    public void RequestHitbox(bool turnOn, float damage, float power)
    {
        throw new System.NotImplementedException();
    }

    public void RequestStopMovement()
    {
        entPhys.currentVelocity = Vector3.zero;
        //rb.velocity = Vector3.zero;
        //rb.angularVelocity = Vector3.zero;
        //rb.isKinematic = true;
    }


    public void ActivateHitbox(bool turnOn, float power, float knockBackPwr)
    {
        if (hitboxController == null) return;
        hitboxController.HitboxActivation(turnOn, power, knockBackPwr);
    }


    private void DashEventReceiver(object sender, System.EventArgs e)
    {
        if (CO_OnKnockback != null) return;
        if (currentState == PlayerStates.Dashing || CO_Dashing != null) return;
        AttackEnds();
        currentState = PlayerStates.Dashing;
        CO_Dashing = StartCoroutine(DashDuration());
    }

    Coroutine CO_Dashing; 
    IEnumerator DashDuration()
    {
        Physics.IgnoreLayerCollision(playerLayer, enemyLayer, true);
        
        var flt_Count = 0f;
        var flt_Length = 0.5f;
        var b_dashEnded = false;

        animComms.RequestPlayAnimation((int)GenericAnimEnums.DASH, 1, 0f, false, true);
        entPhys.collisionLayers = ~LayerMask.GetMask("Enemies", "Hurtbox");

        if (MoveDir.x > 0 || MoveDir.x < 0)
        {
            while (flt_Count < flt_Length)
            {
                if (flt_Count < 0.3f && !b_dashEnded)
                {
                    Vector3 dir = transform.position + MoveDir;
                    Vector3 lookDir = new Vector3(dir.x, transform.position.y, transform.position.z);
                    transform.LookAt(lookDir);
                    entPhys.currentVelocity = MoveDir * 20f;
                }
                if (flt_Count >= 0.3f && !b_dashEnded)
                {
                    b_dashEnded = true;
                    currentState = PlayerStates.Idle;
                    entPhys.currentVelocity = Vector3.zero;
                }
                flt_Count += Time.deltaTime;
                yield return null;
            }
        }
        else if (MoveDir == Vector3.zero)
        { 
            while(flt_Count < flt_Length)
            {
                if (flt_Count < 0.3f && !b_dashEnded) 
                { 
                    Vector3 dir = transform.position + entPhys.currentVelocity;
                    Vector3 lookDir = new Vector3(dir.x, transform.position.y, transform.position.z);
                    transform.LookAt(lookDir);
                    entPhys.currentVelocity = transform.forward * 20f;
                }
                if (flt_Count >= 0.3f && !b_dashEnded)
                {
                    b_dashEnded = true;
                    currentState = PlayerStates.Idle;
                    entPhys.currentVelocity = Vector3.zero;
                }
                flt_Count += Time.deltaTime;
                yield return null;
            }

        }
        entPhys.collisionLayers = entPhys.defaultcollisionLayers;
        CO_Dashing = null;
        AttackEnds();
    }


    private void LogicMovement()
    {
        MoveDir = new Vector3(inputManager.GetMovementAxis().x, 0f, inputManager.GetMovementAxis().y);
        if (CO_OnKnockback != null) return;
        if (currentState == PlayerStates.Dashing || currentState == PlayerStates.Attacking) return;
        if (MoveDir == Vector3.zero && GroundCheck() == true) { animComms.RequestPlayAnimation((int)GenericAnimEnums.IDLE, 1, 0, false, false); entPhys.currentVelocity.x = 0f; return; }

        var vect3_lookDir = new Vector3(transform.position.x + MoveDir.x, transform.position.y, transform.position.z);
        transform.LookAt(vect3_lookDir);
        entPhys.currentVelocity.x = MoveDir.x * 7.5f;
        animComms.RequestPlayAnimation((int)GenericAnimEnums.WALKFWD, 1, 0, false, false);

    }

    private bool GroundCheck()
    {
        bool onGround = Physics.Raycast(transform.position + transform.up, Vector3.down, 1.2f);
        if (onGround)
        {
            numOfJumpsMidAir = 1;
            //if (!rb.isKinematic && currentState != PlayerStates.Dashing && CO_EarlyJumpBoost == null && currentState != PlayerStates.Attacking && CO_OnKnockback == null) { rb.isKinematic = true; }

            return true;
        }
        else
        {
            //if (rb.isKinematic) { rb.isKinematic = false; }

            return false; 
        } 
    }



    public void DealDamage(float damage, Vector3 dir, float knckBackPwr)
    {
        if (CO_Dashing != null || CO_OnKnockback != null) return;
        if (healthController.GetCurrentHealth() < 1 && damage > 0) return;
        ParticleRequestParams parameter = new ParticleRequestParams(ParticleTypes.BLOODHIT, transform.position + transform.up * 0.7f, Vector3.zero, Vector3.one, transform, true);
        ParticlesVFXManager.instance.RequestParticleVFX(parameter);
        KnockEntityBack(dir, knckBackPwr);
        healthController.HealthChange(-damage);
        if (healthController.GetCurrentHealth() < 1) 
        { 
            Debug.Log("Player dead!"); 
            GameManager.instance.ActivateGameOverScreen();
        }
    }


    public void KnockEntityBack(Vector3 direction, float power)
    {
        if (CO_OnKnockback != null) return;
        if (CO_Dashing != null)
        {
            StopCoroutine(CO_Dashing);
            CO_Dashing = null;
            animComms.RequestPlayAnimation((int)GenericAnimEnums.IDLE, 1, 0, false, true);
        }
        AttackEnds();
        animComms.RequestPlayAnimation((int)GenericAnimEnums.IDLE, 1, 0, false, false);
        CO_OnKnockback = StartCoroutine(OnKnockback(direction, power));
    }
    Coroutine CO_OnKnockback;
    IEnumerator OnKnockback(Vector3 direction, float power)
    {

        var flt_Count = 0f;
        var flt_Duration = 0.15f;
        rb.isKinematic = false;
        entPhys.currentVelocity = new Vector3(direction.x, 0f, 0f) * power;
        ActivateHitbox(false, 0f, 0f);

        while (flt_Count <= flt_Duration)
        {
            flt_Count += Time.fixedDeltaTime;
            yield return new WaitForFixedUpdate();
        }
        CO_OnKnockback = null;
    }


    private void AnimationTriggerEventReceiver(object sender, IAnimationEventSender.AnimationEventTriggerArgs e)
    {
        if (e.animtype == (int)AnimationEventTypes.AttackCombo)
        {
            if (e.index == 1)
            {
                canCombo = true;
                if (maxCombos > currentCombo) { currentCombo++; }
            }
            else
            {
                canCombo = false;
                currentCombo = 0;
            }
        }
        if (e.animtype == (int)AnimationEventTypes.AttackEvent)
        {
            if (currentAbillity == null) return;
            currentAbillity.AnimEvents(e.index);
        }
    }


    public void ReloadPlayer()
    {
        canCombo = false;
        numOfJumpsMidAir = 1;
        if (CO_Dashing != null) { StopCoroutine(CO_Dashing); CO_Dashing = null; }
        if (CO_OnKnockback != null) { StopCoroutine(CO_OnKnockback); CO_OnKnockback = null; }
        DealDamage(-1000f, Vector3.zero, 0f);
        rb.velocity = Vector3.zero;
        currentState = PlayerStates.Idle;
    }


    // Update is called once per frame
    void Update()
    {
         GroundCheck();
    }

    private void FixedUpdate()
    {
        LogicMovement();
    }


    /*List of elements that should be adjusted so that it will be similar to Hollow Knight:
    1. Responsive physics, such as quick jump and fall velocity
    2. Clear Boss telegraph attack, the player should register clearly what attack is coming and 
    3. Clear visual feedback elements, adding visual effects and animations so it can help the player recognize what is going on
    */
}
