using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IHitboxController
{
    public void HitboxActivation(bool turnOn, float damage, float knckBackPwr);
}
