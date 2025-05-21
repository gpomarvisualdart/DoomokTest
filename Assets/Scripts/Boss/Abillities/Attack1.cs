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
                var dict_AdditionalInfo = new Dictionary<MovementAdditionalInfo , int>();
                abillityRequests.RequestMovement(transform.forward, 30f, 0f, false, dict_AdditionalInfo);
                break;
            case 1:
                if (abillityRequests == null) return;
                abillityRequests.RequestHitbox(true, power, 7.5f);
                break;
            case 2:
                if (abillityRequests == null) return;
                abillityRequests.RequestStopMovement();
                break;
            case 3:
                if (abillityRequests == null) return;
                abillityRequests.RequestHitbox(false, power, 7.5f);
                break;
             case 4:
                AttackEnds();
                break;
        }
        
    }


    public override void Execute()
    {
        animComms.RequestPlayAnimation((int)BossAnimEnums.ATTACK1, 0, 0f, true, true);
    }


    public override void AttackEnds()
    {
        lgcBoss.AttackEnds();
    }
}
