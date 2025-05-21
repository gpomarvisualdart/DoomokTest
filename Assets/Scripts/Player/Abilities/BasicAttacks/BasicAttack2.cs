using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasicAttack2 : Abillity
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
                Debug.LogError("No AnimEvents index!");
                break;
            case 0:
                abillityRequests.RequestMovement(transform.forward, 10, 0, false, null);
                break;
            case 1:
                if (lgcPlr == null) return;
                lgcPlr.ActivateHitbox(true, power, 0f);
                break;
            case 2:
                abillityRequests.RequestStopMovement();
                break;
            case 3:
                if (lgcPlr == null) return;
                lgcPlr.ActivateHitbox(false, power, 0f);
                break;
            case 4:
                AttackEnds();
                break;
        }
    }

    public override void AttackEnds()
    {
        lgcPlr.AttackEnds();
    }

    public override void Execute()
    {
        animComms.RequestPlayAnimation((int)GenericAnimEnums.ATTACK2START, 1, 0, true, false);
    }
}
