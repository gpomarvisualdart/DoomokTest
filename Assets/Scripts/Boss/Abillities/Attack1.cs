using System.Collections;
using System.Collections.Generic;
using System.Linq.Expressions;
using UnityEngine;

public class D_Attack1 : Abillity
{
    private LogicBoss lgcBoss;
    private IGenericAbillityRequests abillityRequests;
    private AnimationComms animComms;


    void OnEnable()
    {
        if (lgcBoss == null || animComms == null || abillityRequests == null)
        {
            lgcBoss = transform.parent.parent.TryGetComponent(out LogicBoss lb) ? lb : null;
            abillityRequests = transform.parent.parent.TryGetComponent(out IGenericAbillityRequests ab) ? ab : null;
            animComms = transform.parent.parent.GetComponentInChildren<AnimationComms>();
            if (lgcBoss == null || animComms == null || abillityRequests == null) {Debug.LogError($"Missing scripts on {this.name}!"); return;}
        }
    }


    public override void AnimEvents(int index)
    {
        switch (index)
        {
            default:
                Debug.LogError("No AnimEvents index!");
                break;
            case 0:
                if (abillityRequests == null) return;
                abillityRequests.RequestMovement(transform.forward * 30f, 0f, false);
                break;
            case 1:
                if (abillityRequests == null) return;
                abillityRequests.RequestStopMovement();
                break;
            case 2:
                
                break;
        }
        
    }


    public override void Execute()
    {
        animComms.RequestPlayAnimation((int)BaseAnimEnums.ATTACK1, 0, true, false);
    }


    public override void AttackEnds()
    {
        throw new System.NotImplementedException();
    }
}
