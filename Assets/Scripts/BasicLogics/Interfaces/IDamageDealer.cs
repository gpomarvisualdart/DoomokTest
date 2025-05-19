using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDamageDealer
{
    public void DealDamage(float damage, Vector3 dir, float knckBackPwr);
}
