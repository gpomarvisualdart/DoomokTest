using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using Random = UnityEngine.Random;

public class LogicBoss : MonoBehaviour, IGenericAbillityRequests
{
    LogicPlayer plr;
    AnimationComms animComms;
    Rigidbody rb;
    public BossStates currentState;
    BossStates defaultState;


    [SerializeField] List<Abillity> abillities;
    Abillity currentAbillity;
    int playerLayer;
    int enemyLayer;


    float defaultAttackChance = 0.45f;
    float defaultWalkFwdChance = 0.3f;
    float defaultWalkBckChance = 0.2f;


    float currentAttackChance = 0.45f;
    float currentWalkFwdChance = 0.3f;
    float currentWalkBckChance = 0.2f;


    float minAtkDist = 5.5f;


    private void OnEnable()
    {
        rb = GetComponent<Rigidbody>();
        currentState = BossStates.WalkForwardTracking;
        animComms = GetComponentInChildren<AnimationComms>();
        if (animComms == null) Debug.Log("AnimComms not found!");

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
        if (currentState != BossStates.WalkForwardTracking) return;
        if (plr == null) return;
        
        var vect3_dir = (plr.transform.position - transform.position);
        var flt_distance = Vector3.Distance(plr.transform.position, transform.position);
        Vector3 lookDir = transform.position + vect3_dir;
        lookDir.y = transform.position.y;
        lookDir.z = transform.position.z;
        transform.LookAt(lookDir);

        if (flt_distance < 5f) { currentState = BossStates.Calculating; return; }

        var vect3_MoveDir = new Vector3(vect3_dir.x, 0, vect3_dir.z).normalized;
        rb.MovePosition(rb.position + vect3_MoveDir * 3 * Time.fixedDeltaTime);
        MovementAnimation(vect3_MoveDir);
    }



    float backwardTimeCount = 0f;
    float backwardTimeMax;


    private void TrackTargetBackward()
    {
        if (currentState != BossStates.WalkBackwardTracking) return;
        if (plr == null) return;

        backwardTimeCount += Time.fixedDeltaTime;
        
        var vect3_dir = (plr.transform.position - transform.position);
        var flt_distance = Vector3.Distance(plr.transform.position, transform.position);
        if (flt_distance > 7f) { currentState = BossStates.WalkForwardTracking; backwardTimeCount = 0f; return; }

        Vector3 lookDir = transform.position + vect3_dir;
        lookDir.y = transform.position.y;
        lookDir.z = transform.position.z;
        transform.LookAt(lookDir);

        if (backwardTimeCount > backwardTimeMax) 
        { 
            currentState = BossStates.Calculating; 
            backwardTimeCount = 0f;  
            return; 
        }

        var vect3_MoveDir = new Vector3(vect3_dir.x, 0, vect3_dir.z).normalized;
        rb.MovePosition(rb.position - vect3_MoveDir * 2 * Time.fixedDeltaTime);
        MovementAnimation(-vect3_MoveDir);
    }


    private void Calculating()
    {
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
        if (currentAbillity != null) return;
        if (abillities.Count < 1) return;
        currentAbillity = abillities[0];
        abillities[0].Execute();        
    }


    public void AttackEnds()
    {
        currentAbillity = null;
        CO_AttackCooldown = StartCoroutine(OnAttackCooldown());
        currentState = BossStates.Calculating;
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



    public void RequestMovement(Vector3 direction, float duration, bool isDynamic)
    {
        if (!isDynamic)
        {
            StaticMovement(direction);
        }
        else
        {
            DynamicMovement(direction, duration);
        }
    }
    private void StaticMovement(Vector3 dir)
    {
        Physics.IgnoreLayerCollision(enemyLayer, playerLayer, true);
        rb.velocity += dir;
    }
    Coroutine CO_OnDynamicMovement;
    private void DynamicMovement(Vector3 dir, float duration)
    {
        if (CO_OnDynamicMovement != null) return;
        Physics.IgnoreLayerCollision(enemyLayer, playerLayer, true);
        CO_OnDynamicMovement = StartCoroutine(OnDynamicMovement(dir, duration));

    }
    IEnumerator OnDynamicMovement(Vector3 dir, float duration)
    {
        var flt_Count = 0f;
        var vect3_thisDir = dir;

        while (flt_Count <= duration)
        {
            var b_FrontNotClear = Physics.Raycast(transform.position, vect3_thisDir);
            if (b_FrontNotClear) vect3_thisDir = -vect3_thisDir;
            rb.MovePosition(rb.position + vect3_thisDir * Time.fixedDeltaTime);
            flt_Count += Time.fixedDeltaTime;
            yield return new WaitForFixedUpdate();
        }
        CO_OnDynamicMovement = null;
    }

    public void RequestJump(Vector3 position, Dictionary<string, int> additionalData, float duration)
    {
        throw new NotImplementedException();
    }

    public void RequestAirSlam(Vector3 position, Dictionary<string, int> additionalData, float duration)
    {
        throw new NotImplementedException();
    }

    public void RequestStopMovement()
    {
        rb.velocity = Vector3.zero;
        Physics.IgnoreLayerCollision(enemyLayer, playerLayer, false);
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
                Debug.Log("Aggro!");
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
        }
    }



    private void MovementAnimation(Vector3 direction)
    {
        if (currentState == BossStates.WalkForwardTracking || currentState == BossStates.WalkBackwardTracking)
        {
            var flt_DotDir = Vector3.Dot(transform.forward, direction);
            if (animComms == null) { Debug.LogError("No animation comms"); return; }
            if (flt_DotDir > 0f) animComms.RequestPlayAnimation((int)BaseAnimEnums.WALKFWD, 0, false, false);
            else animComms.RequestPlayAnimation((int)BaseAnimEnums.WALKBCK, 0, false, false);
        }
    }


    private void AnimationEndsEventReceiver(object sender, IAnimationEventSender.AnimationEndsEventArgs e)
    {
        if (e.animType == (int)AnimationTypes.Attack)
        {
            AttackEnds();
        }
    }


    private void AnimationTriggerEventReceiver(object sender, IAnimationEventSender.AnimationEventTriggerArgs e)
    {
        if ((AnimationTypes)e.animtype == AnimationTypes.Attack)
        {
            if (currentAbillity == null) return;
            currentAbillity.AnimEvents(e.index);
        }
    }


    // Update is called once per frame
    void Update()
    {
        StateController();
    }

    private void FixedUpdate()
    {
        TrackTarget();
        TrackTargetBackward();
    }
}
