using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IEntityKnockback
{
    public void KnockEntityBack(Vector3 direction, float power);
}
