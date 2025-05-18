using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Skill1 : Abillity
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
        throw new System.NotImplementedException();
    }

    public override void AttackEnds()
    {
        animComms.RequestPlayAnimation((int)BaseAnimEnums.SKILL1, 0, true, false);
    }

    public override void Execute()
    {
        
    }
}
