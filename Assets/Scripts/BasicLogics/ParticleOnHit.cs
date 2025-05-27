using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleOnHit : MonoBehaviour
{
    ParticleSystem prtsys;

    private void OnEnable()
    {
        if (prtsys == null)
        {
            if (transform.childCount < 1) return;
            for (int i = 0; i < transform.childCount; i++)
            {
                Transform child = transform.GetChild(i);
                if (!child.TryGetComponent(out ParticleSystem ps)) continue;
                prtsys = ps;
                return;
            }
        }
    }

    public void ActivateHurtParticle()
    {
      if (prtsys == null) return;
      prtsys.Play();
    }
}
