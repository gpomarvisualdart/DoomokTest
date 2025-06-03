using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using ParticleData;
using Random = UnityEngine.Random;

public class LogicBoss : MonoBehaviour, IGenericAbillityRequests, IDamageDealer
{
    LogicPlayer plr;
    AnimationComms animComms;
    Collider col;
    EntityCapsulePhysicsController entPhys;
    public BossStates currentState;
    BossStates defaultState;
    IEntityHealthController healthController;
    public Transform GetBossTransform() { return transform; }
    Vector3 MoveDir;
    bool canLookTowardBeforeAttack = true;


    [SerializeField] List<Abillity> abillities;
    Abillity currentAbillity;
    Abillity lastUsedAbillity;
    int playerLayer;
    int enemyLayer;


    float defaultAttackChance = 0.45f;
    float defaultWalkFwdChance = 0.3f;
    float defaultWalkBckChance = 0.2f;


    float currentAttackChance = 0.45f;
    float currentWalkFwdChance = 0.3f;
    float currentWalkBckChance = 0.2f;


    float minAtkDist = 5.5f;

    bool canAttackFromFar = true;


    [SerializeField] Transform hitboxTransform;
    IHitboxController hitBox;


    private void OnEnable()
    {
        WakeDelay();
        col = GetComponent<Collider>();
        entPhys = GetComponent<EntityCapsulePhysicsController>();
        currentState = BossStates.Idle;
        healthController = TryGetComponent(out IEntityHealthController ieh) ? ieh : null;
        if (healthController == null) Debug.LogError("No health controller!");
        currentState = BossStates.WalkForwardTracking;
        animComms = GetComponentInChildren<AnimationComms>();
        hitBox = hitboxTransform.TryGetComponent(out IHitboxController ihb) ? ihb : null;
        if (animComms == null) Debug.LogError("AnimComms not found!");
        if (hitBox == null) Debug.LogError("Hitbox not found!");

        animComms.AnimationEndsEvent += AnimationEndsEventReceiver;
        animComms.AnimationTriggerEvent += AnimationTriggerEventReceiver;
        playerLayer = LayerMask.NameToLayer("Player");
        enemyLayer = LayerMask.NameToLayer("Enemies");
    }


    void Start()
    {
        plr = FindObjectOfType<LogicPlayer>();
    }


    Coroutine CO_DelayBeforeWake;
    private void WakeDelay()
    {
        if (CO_DelayBeforeWake != null) return;
        CO_DelayBeforeWake = StartCoroutine(DelayBeforeWake());
    }
    IEnumerator DelayBeforeWake()
    {
        var flt_Count = 0f;
        var flt_MaxCount = 1f;
        while (flt_Count <= flt_MaxCount)
        {
            flt_Count += Time.deltaTime;
            yield return null;
        }
        CO_DelayBeforeWake = null;
    }


    private void TrackTarget()
    {
        if (CO_DelayBeforeWake != null) return;
        if (plr == null) return;
        MoveDir = new Vector3(plr.GetPlayerTransform().position.x, 0f, plr.GetPlayerTransform().position.z) - new Vector3(transform.position.x, 0f, transform.position.z);
        if (currentState != BossStates.WalkForwardTracking) return;
        if (!GroundCheck()) return;

        var flt_distance = Vector3.Distance(plr.transform.position, transform.position);
        Vector3 lookDir = transform.position + MoveDir;
        lookDir.y = transform.position.y;
        lookDir.z = transform.position.z;
        transform.LookAt(lookDir);

        if (flt_distance >= 7.7f && canAttackFromFar) { entPhys.currentVelocity = Vector3.zero; currentState = BossStates.Attack; return; }
        if (flt_distance <= minAtkDist) { entPhys.currentVelocity = Vector3.zero; currentState = BossStates.Calculating; return; }
        entPhys.currentVelocity = MoveDir.normalized * 3;
        MovementAnimation(MoveDir);
    }



    float backwardTimeCount = 0f;
    float backwardTimeMax;
    private void TrackTargetBackward()
    {
        if (CO_DelayBeforeWake != null) return;
        if (plr == null) return;
        MoveDir = new Vector3(plr.GetPlayerTransform().position.x, 0f, plr.GetPlayerTransform().position.z) - new Vector3(transform.position.x, 0f, transform.position.z);
        if (currentState != BossStates.WalkBackwardTracking) return;
        if (!GroundCheck()) return;

        backwardTimeCount += Time.fixedDeltaTime;
        
        var flt_distance = Vector3.Distance(plr.transform.position, transform.position);
        if (flt_distance >= 7.7f && canAttackFromFar) { entPhys.currentVelocity = Vector3.zero; currentState = BossStates.Attack; return; }    
        if (flt_distance >= 7f) { entPhys.currentVelocity = Vector3.zero; currentState = BossStates.WalkForwardTracking; backwardTimeCount = 0f; return; }

        Vector3 lookDir = transform.position + MoveDir;
        lookDir.y = transform.position.y;
        lookDir.z = transform.position.z;
        transform.LookAt(lookDir);

        if (backwardTimeCount > backwardTimeMax) 
        { 
            currentState = BossStates.Calculating; 
            backwardTimeCount = 0f;
            entPhys.currentVelocity = Vector3.zero;
            return; 
        }
        entPhys.currentVelocity = -MoveDir.normalized * 2;
        MovementAnimation(-MoveDir);
    }


    private void Calculating()
    {
        if (CO_DelayBeforeWake != null) return;
        if (currentState != BossStates.Calculating) return;
        float randomChance = Random.Range(0f, 1f);

        if (randomChance >= currentAttackChance)
        {
            if (currentState == BossStates.Attack || CO_AttackCooldown != null) return;
            if (plr == null) return;
            var v3_dist = Vector3.Distance(plr.GetPlayerTransform().position, transform.position);
            //if (v3_dist > minAtkDist) { currentState = BossStates.WalkForwardTracking; return;}
            currentState = BossStates.Attack;
            
        }
        else if (randomChance >= currentWalkFwdChance)
        {
            if (currentState == BossStates.WalkForwardTracking) return;
            currentState = BossStates.WalkForwardTracking;
        }
        else if (randomChance >= currentWalkBckChance)
        {
            if (currentState == BossStates.WalkBackwardTracking) return;
            backwardTimeMax = Random.Range(0.2f, 0.4f);
            currentState = BossStates.WalkBackwardTracking;
        }
    }


    public void CanLookBeforeAttack(bool canLook) { canLookTowardBeforeAttack = canLook; }

    private void StartAttack()
    {
        if (CO_DelayBeforeWake != null) return;
        if (plr == null) { currentState = BossStates.Calculating; return; }
        var flt_distance = Vector3.Distance(plr.GetPlayerTransform().position, transform.position);
        if (canLookTowardBeforeAttack) 
        {
            Vector3 lookDir = transform.position + MoveDir;
            lookDir.y = transform.position.y;
            lookDir.z = transform.position.z;
            transform.LookAt(lookDir);
        }

        if (currentState != BossStates.Attack) return;
        if (currentAbillity != null) return;
        if (abillities.Count < 1) return;
        var int_RandomAttack = Random.Range(0, abillities.Count);
        if (lastUsedAbillity == abillities[int_RandomAttack]) return;
        if (int_RandomAttack == 0 && flt_distance > 7.7f) return;
        if (int_RandomAttack != 0 && !canAttackFromFar) { currentState = BossStates.WalkForwardTracking; return; }
        currentAbillity = abillities[int_RandomAttack];
        if (int_RandomAttack == 0) canAttackFromFar = true;
        currentAbillity.Execute();        
    }


    public void AttackEnds()
    {
        if (CO_DelayBeforeWake != null) return;
        currentState = BossStates.Calculating;
        lastUsedAbillity = currentAbillity;
        currentAbillity = null;
        canLookTowardBeforeAttack = true;
        CO_AttackCooldown = StartCoroutine(OnAttackCooldown());
        var flt_disableFarAttackChance = Random.Range(0f, 1f);
        if (flt_disableFarAttackChance < 0.4f && abillities[0] != lastUsedAbillity) canAttackFromFar = false;
    }
    

    Coroutine CO_AttackCooldown;
    IEnumerator OnAttackCooldown()
    {
        var flt_count = 0f;
        var flt_MaxTime = 0.3f;
        while (flt_count < flt_MaxTime)
        {
            flt_count += Time.deltaTime;
            yield return null;
        }
        CO_AttackCooldown = null;
    }


    public void RequestMovement(Vector3 direction, float spd, float duration, bool isDynamic, Dictionary<MovementAdditionalInfo, int> additionalInfo)
    {
        if (!isDynamic)
        {
            StaticMovement(direction, spd, additionalInfo);
        }
        else
        {
            DynamicMovement(direction, spd, duration, additionalInfo);
        }
    }
    private void StaticMovement(Vector3 dir, float spd, Dictionary<MovementAdditionalInfo, int> addInfo)
    {
        dir.y = 0f;
        entPhys.currentVelocity = dir * spd;
        entPhys.collisionLayers = ~LayerMask.GetMask("Player", "Hurtbox", "Hitbox");
    }
    Coroutine CO_OnDynamicMovement;
    private void DynamicMovement(Vector3 dir, float spd, float duration, Dictionary<MovementAdditionalInfo, int> addInfo)
    {
        if (CO_OnDynamicMovement != null) return;
        CO_OnDynamicMovement = StartCoroutine(OnDynamicMovement(dir, spd, duration, addInfo));
        entPhys.collisionLayers = ~LayerMask.GetMask("Player", "Hurtbox", "Hitbox");

    }
    IEnumerator OnDynamicMovement(Vector3 dir, float spd, float duration, Dictionary<MovementAdditionalInfo, int> addInfo)
    {
        var flt_Count = 0f;
        dir.y = 0f;
        var vect3_thisDir = dir;
        int mask = ~addInfo[MovementAdditionalInfo.Layers];

        while (flt_Count <= duration)
        {
            var b_FrontNotClear = Physics.Raycast(transform.position, vect3_thisDir, spd * Time.fixedDeltaTime * 4f, mask);
            if (b_FrontNotClear) { vect3_thisDir = -vect3_thisDir; }
            transform.LookAt(new Vector3(transform.position.x + vect3_thisDir.x, transform.position.y, transform.position.z));
            entPhys.currentVelocity = vect3_thisDir * spd;
            flt_Count += Time.fixedDeltaTime;
            Debug.Log(vect3_thisDir);
            yield return new WaitForFixedUpdate();
        }
        CO_OnDynamicMovement = null;
    }


    Coroutine CO_OnJump;
    public void RequestJump(Vector3 position, Dictionary<JumpAdditionalInfo, int> additionalData, float duration)
    {
        throw new NotImplementedException();
    }


    public void RequestAirSlam(Vector3 position, Dictionary<JumpAdditionalInfo, int> additionalData, float duration)
    {
        throw new NotImplementedException();
    }

    public void RequestHitbox(bool turnOn, float damage, float power)
    {
        hitBox.HitboxActivation(turnOn, damage, power);
    }


    public void RequestStopMovement()
    {
        if (CO_OnDynamicMovement != null) {  StopCoroutine(CO_OnDynamicMovement); CO_OnDynamicMovement = null; }

        entPhys.collisionLayers = entPhys.defaultcollisionLayers;
        entPhys.currentVelocity = Vector3.zero;
    }


    public void DealDamage(float damage, Vector3 dir, float knckBackPwr)
    {
        if (healthController == null) return;
        if (healthController.GetCurrentHealth() < 1) return;
        if (CO_DelayBeforeWake != null) { StopCoroutine(CO_DelayBeforeWake); CO_DelayBeforeWake = null; }

        healthController.HealthChange(-damage);

        ParticleRequestParams param = new ParticleRequestParams(ParticleTypes.BLOODHIT, transform.position + transform.up * 1.5f, Vector3.zero, new Vector3(1.5f, 1.5f, 1.5f), transform, true);
        ParticlesVFXManager.instance.RequestParticleVFX(param);

        if (healthController.GetCurrentHealth() < 1f)
        {
            RequestStopMovement();
            col.enabled = false;
            currentState = BossStates.Die;
        }
    }

    private void StateController()
    {
        if (CO_DelayBeforeWake != null) return;
        switch (currentState)
        {
            default:
                Debug.LogError("No state defined!");
                currentState = BossStates.Calculating;
                break;

            case BossStates.Idle:
                 
                break;

            case BossStates.Calculating:
                Calculating(); break;

            case BossStates.Aggro:
                //Debug.Log("Aggro!");
                currentState = BossStates.WalkForwardTracking;
                break;

            case BossStates.WalkForwardTracking:
                break;

            case BossStates.WalkBackwardTracking:
                currentState = BossStates.WalkBackwardTracking;
                break;

            case BossStates.Attack:
                StartAttack();
                break;
            case BossStates.Die:
                currentAbillity = null;
                animComms.RequestPlayAnimation((int)BossAnimEnums.DEATH, 0, 0f, true, true);
                Physics.IgnoreLayerCollision(enemyLayer, playerLayer, true);
                break;
        }
    }



    private void MovementAnimation(Vector3 direction)
    {
        if (CO_DelayBeforeWake != null) return;
        if (currentState == BossStates.WalkForwardTracking || currentState == BossStates.WalkBackwardTracking)
        {
            var flt_DotDir = Vector3.Dot(transform.forward, direction);
            if (animComms == null) { Debug.LogError("No animation comms"); return; }
            if (flt_DotDir > 0f) animComms.RequestPlayAnimation((int)BossAnimEnums.WALKFWD, 0, 0, false, false);
            else animComms.RequestPlayAnimation((int)BossAnimEnums.WALKBCK, 0, 0, false, false);
        }
    }


    private void AnimationEndsEventReceiver(object sender, IAnimationEventSender.AnimationEndsEventArgs e)
    {
        if (CO_DelayBeforeWake != null) return;
        if (e.animType == (int)AnimationEventTypes.AttackEvent)
        {
            AttackEnds();
        }
    }


    private void AnimationTriggerEventReceiver(object sender, IAnimationEventSender.AnimationEventTriggerArgs e)
    {
        if (CO_DelayBeforeWake != null) return;
        if ((AnimationEventTypes)e.animtype == AnimationEventTypes.AttackEvent)
        {
            if (currentAbillity == null) return;
            currentAbillity.AnimEvents(e.index);
        }
    }


    private bool GroundCheck()
    {
        bool onGround = Physics.Raycast(transform.position + transform.up * (1.5f / 2), Vector3.down, 1.5f / 2 + 0.1f);
        Vector3 rayOrigin = transform.position + transform.up * (1.5f / 2);
        Vector3 rayDirection = Vector3.down * (1.5f / 2);
        Debug.DrawRay(rayOrigin, rayDirection, Color.red);
        if (onGround)
        {

            return true;
        }
        else
        {

            return false;
        }
    }


    // Update is called once per frame
    void Update()
    {
        StateController();
        GroundCheck();
    }

    private void FixedUpdate()
    {
        TrackTarget();
        TrackTargetBackward();
    }
}
