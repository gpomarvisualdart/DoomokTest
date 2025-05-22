using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using Random = UnityEngine.Random;

public class LogicBoss : MonoBehaviour, IGenericAbillityRequests, IDamageDealer
{
    LogicPlayer plr;
    AnimationComms animComms;
    Rigidbody rb;
    public BossStates currentState;
    BossStates defaultState;
    IEntityHealthController healthController;
    public Transform GetBossTransform() { return rb.transform; }
    Vector3 MoveDir;


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


    [SerializeField] Transform hitboxTransform;
    IHitboxController hitBox;


    private void OnEnable()
    {
        rb = GetComponent<Rigidbody>();
        rb.isKinematic = true;
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



    private void TrackTarget()
    {
        if (plr == null) return;
        MoveDir = (plr.transform.position - transform.position);
        if (currentState != BossStates.WalkForwardTracking) return;
        if (!GroundCheck()) return;

        var flt_distance = Vector3.Distance(plr.transform.position, transform.position);
        Vector3 lookDir = transform.position + MoveDir;
        lookDir.y = transform.position.y;
        lookDir.z = transform.position.z;
        transform.LookAt(lookDir);

        if (flt_distance < 5f) { currentState = BossStates.Calculating; return; }
        rb.MovePosition(rb.position + MoveDir.normalized * 3 * Time.fixedDeltaTime);
        MovementAnimation(MoveDir);
    }



    float backwardTimeCount = 0f;
    float backwardTimeMax;


    private void TrackTargetBackward()
    {
        if (plr == null) return;
        MoveDir = (plr.transform.position - transform.position);

        if (currentState != BossStates.WalkBackwardTracking) return;
        if (!GroundCheck()) return;

        backwardTimeCount += Time.fixedDeltaTime;
        
        var flt_distance = Vector3.Distance(plr.transform.position, transform.position);
        if (flt_distance > 7f) { currentState = BossStates.WalkForwardTracking; backwardTimeCount = 0f; return; }

        Vector3 lookDir = transform.position + MoveDir;
        lookDir.y = transform.position.y;
        lookDir.z = transform.position.z;
        transform.LookAt(lookDir);

        if (backwardTimeCount > backwardTimeMax) 
        { 
            currentState = BossStates.Calculating; 
            backwardTimeCount = 0f;  
            return; 
        }
        rb.MovePosition(rb.position - MoveDir.normalized * 2 * Time.fixedDeltaTime);
        MovementAnimation(-MoveDir);
    }


    private void Calculating()
    {
        if (currentState != BossStates.Calculating) return;
        float randomChance = Random.Range(0f, 1f);

        if (randomChance >= currentAttackChance)
        {
            if (currentState == BossStates.Attack || CO_AttackCooldown != null) return;
            if (plr == null) return;
            var v3_dist = Vector3.Distance(plr.GetPlayerTransform().position, transform.position);
            if (v3_dist > minAtkDist) { currentState = BossStates.WalkForwardTracking; return;}
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
            currentState = BossStates.WalkBackwardTracking;
        }
    }


    private void StartAttack()
    {
        if (currentState != BossStates.Attack) return;
        if (currentAbillity != null) return;
        if (abillities.Count < 1) return;
        var int_RandomAttack = Random.Range(0, abillities.Count);
        if (lastUsedAbillity == abillities[int_RandomAttack]) return;
        currentAbillity = abillities[int_RandomAttack];
        currentAbillity.Execute();        
    }


    public void AttackEnds()
    {
        currentState = BossStates.Calculating;
        lastUsedAbillity = currentAbillity;
        currentAbillity = null;
        CO_AttackCooldown = StartCoroutine(OnAttackCooldown());
    }
    

    Coroutine CO_AttackCooldown;
    IEnumerator OnAttackCooldown()
    {
        var flt_count = 0f;
        var flt_MaxTime = 1f;
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
        rb.isKinematic = false;
        Physics.IgnoreLayerCollision(enemyLayer, playerLayer, true);
        rb.velocity += dir * spd;
    }
    Coroutine CO_OnDynamicMovement;
    private void DynamicMovement(Vector3 dir, float spd, float duration, Dictionary<MovementAdditionalInfo, int> addInfo)
    {
        if (CO_OnDynamicMovement != null) return;
        Physics.IgnoreLayerCollision(enemyLayer, playerLayer, true);
        rb.isKinematic = false;
        CO_OnDynamicMovement = StartCoroutine(OnDynamicMovement(dir, spd, duration, addInfo));

    }
    IEnumerator OnDynamicMovement(Vector3 dir, float spd, float duration, Dictionary<MovementAdditionalInfo, int> addInfo)
    {
        var flt_Count = 0f;
        var vect3_thisDir = dir;
        int mask = ~addInfo[MovementAdditionalInfo.Layers];

        while (flt_Count <= duration)
        {
            var b_FrontNotClear = Physics.Raycast(transform.position, vect3_thisDir, spd * Time.fixedDeltaTime * 5f, mask);
            if (b_FrontNotClear) { vect3_thisDir = -vect3_thisDir; }
            transform.LookAt(new Vector3(transform.position.x + vect3_thisDir.x, transform.position.y, transform.position.z));
            rb.velocity = vect3_thisDir * spd;
            flt_Count += Time.fixedDeltaTime;
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
        if (CO_OnDynamicMovement != null) { rb.velocity = Vector3.zero; rb.position = transform.position; StopCoroutine(CO_OnDynamicMovement); CO_OnDynamicMovement = null; }
        rb.velocity = Vector3.zero;
        rb.angularVelocity = Vector3.zero;
        rb.isKinematic = true;
        Physics.IgnoreLayerCollision(enemyLayer, playerLayer, false);
    }


    public void DealDamage(float damage, Vector3 dir, float knckBackPwr)
    {
        if (healthController == null) return;
        if (healthController.GetCurrentHealth() < 1) return;

        healthController.HealthChange(-damage);
        //Debug.Log(healthController.GetCurrentHealth());

        if (healthController.GetCurrentHealth() < 1f)
        {
            RequestStopMovement();
            currentState = BossStates.Die;
        }
    }

    private void StateController()
    {
        switch (currentState)
        {
            default:
                Debug.LogError("No state defined!");
                currentState = BossStates.Calculating;
                break;

            case BossStates.Idle:
                rb.velocity = Vector3.zero; break;

            case BossStates.Calculating:
                Calculating(); break;

            case BossStates.Aggro:
                //Debug.Log("Aggro!");
                currentState = BossStates.WalkForwardTracking;
                break;

            case BossStates.WalkForwardTracking:
                break;

            case BossStates.WalkBackwardTracking:
                backwardTimeMax = Random.Range(0.5f, 1f);
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
        if (e.animType == (int)AnimationEventTypes.AttackEvent)
        {
            AttackEnds();
        }
    }


    private void AnimationTriggerEventReceiver(object sender, IAnimationEventSender.AnimationEventTriggerArgs e)
    {
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
        //Debug.Log(rb.velocity);
        if (onGround)
        {
            Debug.Log("On ground!");
            if (!rb.isKinematic && currentState != BossStates.Attack) { rb.isKinematic = true;}
            return true;
        }
        else
        {
            Debug.Log("Not on ground!");
            rb.isKinematic = false;

            return false;
        }
    }


    // Update is called once per frame
    void Update()
    {
        StateController();
        GroundCheck();
    }

    Vector3 lastPos;
    private void FixedUpdate()
    {
        TrackTarget();
        TrackTargetBackward();
    }
}
