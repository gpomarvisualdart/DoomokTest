using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IGenericAbillityRequests
{
    public delegate void RequestedMovement(Vector3 direction, float duration);

    public void RequestMovement(Vector3 direction, float duration, bool isDynamic);

    public void RequestJump(Vector3 position, Dictionary<string, int> additionalData, float duration);

    public void RequestAirSlam(Vector3 position, Dictionary<string, int> additionalData, float duration);

    public void RequestStopMovement();
}
