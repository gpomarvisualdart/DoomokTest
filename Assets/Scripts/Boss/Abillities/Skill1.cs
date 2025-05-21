using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Skill1 : Abillity
{

    private LogicBoss lgcBoss;
    private IGenericAbillityRequests abillityRequests;
    private AnimationComms animComms;

    LayerMask ignoreLayers;


    void OnEnable()
    {
        if (lgcBoss == null || animComms == null || abillityRequests == null)
        {
            lgcBoss = transform.parent.parent.TryGetComponent(out LogicBoss lb) ? lb : null;
            abillityRequests = transform.parent.parent.TryGetComponent(out IGenericAbillityRequests ab) ? ab : null;
            animComms = transform.parent.parent.GetComponentInChildren<AnimationComms>();
            if (lgcBoss == null || animComms == null || abillityRequests == null) {Debug.LogError($"Missing scripts on {this.name}!"); return;}
        }

        ignoreLayers = LayerMask.GetMask("Player", "Enemies", "Hurtbox");
    }


    public override void AnimEvents(int index)
    {
        if (abillityRequests == null) return;
        
        switch(index)
        {
            default:
                Debug.LogError($"{index} is not event index!");
                break;
            case 0:
                if (abillityRequests == null) return;
                var dict_AdditionalInfo = new Dictionary<MovementAdditionalInfo, int>();
                dict_AdditionalInfo[MovementAdditionalInfo.Layers] = ignoreLayers;
                abillityRequests.RequestMovement(transform.forward, 15f, 10f, true, dict_AdditionalInfo);
                break;
            case 1:
                if (abillityRequests == null) return;
                abillityRequests.RequestHitbox(true, power, 25f);
                //Debug.Log("Hit box on!");
                break;
            case 2:
                if (abillityRequests == null) return;
                abillityRequests.RequestHitbox(false, power, 25f);
                //Debug.Log("Hit box is off!");
                break;
            case 3:
                if (abillityRequests == null) return;
                abillityRequests.RequestStopMovement();
                break;
            case 4:
                AttackEnds();
                break;

        }
    }

    public override void AttackEnds()
    {
        lgcBoss.AttackEnds();
    }

    public override void Execute()
    {
        animComms.RequestPlayAnimation((int)BossAnimEnums.SKILL1, 0, 0f, true, false);
    }
}
