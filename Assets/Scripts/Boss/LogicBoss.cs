using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class LogicBoss : MonoBehaviour
{
    LogicPlayer plr;
    AnimationComms animComms;
    Rigidbody rb;
    public BossStates currentState;
    BossStates defaultState;


    float defaultAttackChance = 0.45f;
    float defaultWalkFwdChance = 0.3f;
    float defaultWalkBckChance = 0.2f;


    float currentAttackChance = 0.45f;
    float currentWalkFwdChance = 0.3f;
    float currentWalkBckChance = 0.2f;




    private void OnEnable()
    {
        rb = GetComponent<Rigidbody>();
        currentState = BossStates.WalkForwardTracking;
        animComms = GetComponentInChildren<AnimationComms>();
        if (animComms == null) Debug.Log("AnimComms not found!");
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
            if (currentState == BossStates.Attack) return;
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


    private void Attacking()
    {
        Debug.Log("Attack!");
        currentState = BossStates.Calculating;
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
                backwardTimeMax = Random.Range(0.25f, 0.5f);
                currentState = BossStates.WalkBackwardTracking;
                break;

            case BossStates.Attack:
                Attacking();
                break;
        }
    }



    private void MovementAnimation(Vector3 direction)
    {
        if (currentState == BossStates.WalkForwardTracking || currentState == BossStates.WalkBackwardTracking)
        {
            var flt_DotDir = Vector3.Dot(transform.forward, direction);
            if (animComms == null) { Debug.LogError("No animation comms"); return; }
            if (flt_DotDir > 0f) animComms.RequestPlayAnimation((int)BaseAnimEnums.WALKFWD, false, false);
            else animComms.RequestPlayAnimation((int)BaseAnimEnums.WALKBCK, false, false);
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
