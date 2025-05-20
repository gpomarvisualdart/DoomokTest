using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasicAttack1 : Abillity
{
    private LogicPlayer lgcPlr;
    private IGenericAbillityRequests abillityRequests;
    private AnimationComms animComms;

    void OnEnable()
    {
        if (lgcPlr == null || animComms == null || abillityRequests == null)
        {
            lgcPlr = transform.parent.parent.TryGetComponent(out LogicPlayer lp) ? lp : null;
            abillityRequests = transform.parent.parent.TryGetComponent(out IGenericAbillityRequests ab) ? ab : null;
            animComms = transform.parent.parent.GetComponentInChildren<AnimationComms>();
            if (lgcPlr == null || animComms == null || abillityRequests == null) { Debug.LogError($"Missing scripts on {this.name}!"); return; }
        }
    }


    public override void AnimEvents(int index)
    {
        switch(index)
        {
            default:
                Debug.LogError("No index!");
                break;
            
            case 0:
                abillityRequests.RequestMovement(transform.forward, 10f, 0.1f, false, null);
                break;
            case 1:

                break;
            case 2:
                abillityRequests.RequestStopMovement();
                break;

        }
    }


    public override void AttackEnds()
    {
        throw new System.NotImplementedException();
    }


    public override void Execute()
    {
        animComms.RequestPlayAnimation((int)GenericAnimEnums.ATTACK1START, 1, true, false);
    }
}
