using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LogicPlayer : MonoBehaviour, IDamageDealer, IEntityKnockback, IGenericAbillityRequests
{
    InputManager inputManager;
    Rigidbody rb;
    [SerializeField] PlayerStates currentState;
    IEntityHealthController healthController;
    AnimationComms animComms;

    int numOfJumpsMidAir = 1;
    int currentCombo;
    int maxCombos;
    int playerLayer;
    int enemyLayer;

    [SerializeField] Abillity currentAbillity;

    [SerializeField] List<Abillity> basicAttacks = new List<Abillity>();

    [SerializeField] Transform Hitbox;

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
        if (CO_EarlyJumpBoost != null) StopCoroutine(CO_EarlyJumpBoost);
        rb.velocity = new Vector3(rb.velocity.x, 0, rb.velocity.z);
        CO_EarlyJumpBoost = StartCoroutine(EarlyJumpBoost());
        numOfJumpsMidAir--;
    }
    Coroutine CO_EarlyJumpBoost;
    IEnumerator EarlyJumpBoost()
    {
        var flt_count = 0f;
        var flt_time = 0.2f;
        rb.velocity += new Vector3(0f, 6.5f, 0f);
        while (flt_count < flt_time)
        {
            rb.velocity += new Vector3(0f, 50f * Time.fixedDeltaTime, 0f);
            flt_count += Time.fixedDeltaTime;
            yield return new WaitForFixedUpdate();
        }
        rb.velocity = new Vector3(rb.velocity.x, 4f, rb.velocity.z);
        CO_EarlyJumpBoost = null;
    }


    private void AttackEventReceiver(object sender, System.EventArgs e)
    {
        if (currentState == PlayerStates.Dashing || CO_Dashing != null) return;
        if (basicAttacks.Count < 1) return;
        if (currentAbillity != null && canCombo == false) return;
        currentState = PlayerStates.Attacking;
        currentAbillity = basicAttacks[currentCombo];
        currentAbillity.Execute();
    }


    public void AttackEnds()
    {
        currentAbillity = null;
        canCombo = false;
        currentCombo = 0;
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
        rb.velocity += dir * spd;
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
        rb.velocity = Vector3.zero;
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
        var flt_Length = 0.75f;
        var b_dashEnded = false;

        currentCombo = 0;
        currentAbillity = null;
        animComms.RequestPlayAnimation((int)GenericAnimEnums.DASH, 1, 0f, true, true);
        rb.velocity += transform.forward * 25f;
        while (flt_Count < flt_Length)
        {
            if (flt_Count > 0.3f && !b_dashEnded)
            { currentState = PlayerStates.Idle; rb.velocity = Vector3.zero; b_dashEnded = true; }
            if (flt_Count > 0.5f) Physics.IgnoreLayerCollision(playerLayer, enemyLayer, false);
            flt_Count += Time.fixedDeltaTime;
            yield return new WaitForFixedUpdate();
        }
        CO_Dashing = null;
    }


    private void Movement()
    {
        if (CO_OnKnockback != null) return;
        if (currentState == PlayerStates.Dashing || currentState == PlayerStates.Attacking) return;
        var vect2_MoveDir = inputManager.GetMovementAxis();
        if (vect2_MoveDir == Vector2.zero && GroundCheck() == true) { animComms.RequestPlayAnimation((int)GenericAnimEnums.IDLE, 1, 0, false, false); return; }

        var vect3_MoveDir = new Vector3(vect2_MoveDir.x, 0, 0);
        rb.MovePosition(rb.position + vect3_MoveDir * 6.5f * Time.fixedDeltaTime);
        Vector3 lookDir = new Vector3 (transform.position.x + vect3_MoveDir.x, transform.position.y, transform.position.z);
        transform.LookAt(lookDir);
        animComms.RequestPlayAnimation((int)GenericAnimEnums.WALKFWD, 1, 0,false, false);

    }


    private bool GroundCheck()
    {
        bool onGround = Physics.Raycast(transform.position + transform.up * (transform.localScale.y/2), Vector3.down, transform.localScale.y/2);
        if (onGround)
        {
            numOfJumpsMidAir = 1;


            return true;
        }
        else
        {
            return false; 
        } 
    }



    public void DealDamage(float damage, Vector3 dir, float knckBackPwr)
    {
        if (currentState == PlayerStates.Dashing || CO_OnKnockback != null) return;
        if (healthController.GetCurrentHealth() < 1) return;
        KnockEntityBack(dir, knckBackPwr);
        healthController.HealthChange(-damage);
        if (healthController.GetCurrentHealth() < 1) Debug.Log("Player dead!");
    }


    public void KnockEntityBack(Vector3 direction, float power)
    {
        if (CO_OnKnockback != null) return;
        CO_OnKnockback = StartCoroutine(OnKnockback(direction, power));
    }
    Coroutine CO_OnKnockback;
    IEnumerator OnKnockback(Vector3 direction, float power)
    {
        var flt_Count = 0f;
        var flt_Duration = 0.15f;
        rb.velocity += direction * power;

        while (flt_Count <= flt_Duration)
        {
            flt_Count += Time.fixedDeltaTime;
            yield return new WaitForFixedUpdate();
        }
        rb.velocity = Vector3.zero;
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


    // Update is called once per frame
    void Update()
    {
         GroundCheck();
    }

    private void FixedUpdate()
    {
        Movement();
    }
}
