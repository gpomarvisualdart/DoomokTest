using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDynamicMovementAbilityRequest
{
    public void RequestDynamicMovement(Vector3 direction, float duration);
}
