using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum MovementAdditionalInfo
{
    Layers
}

public enum JumpAdditionalInfo
{
    Layers,
    Height,
    TimeForMaxHeight,
    HasReachedMaxHeight,
    TimeForLanding,
    HasLanded,
}

public interface IGenericAbillityRequests
{
    public delegate void RequestedMovement(Vector3 direction, float duration);

    public void RequestMovement(Vector3 direction, float spd, float duration, bool isDynamic, Dictionary<MovementAdditionalInfo, int> additionalInfo);

    public void RequestJump(Vector3 position, Dictionary<JumpAdditionalInfo, int> additionalData, float duration);

    public void RequestAirSlam(Vector3 position, Dictionary<JumpAdditionalInfo, int> additionalData, float duration);

    public void RequestHitbox(bool turnOn, float damage, float power);

    public void RequestStopMovement();
}
