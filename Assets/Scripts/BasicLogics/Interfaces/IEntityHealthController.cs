using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IEntityHealthController
{
    public void HealthChange(float value);

    public float GetCurrentHealth();
}
