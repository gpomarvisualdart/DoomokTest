using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleObjectController : MonoBehaviour
{
    ParticleHolder holder;
    ParticleSystem ps;

    private void OnEnable()
    {
        if (holder == null) { holder = transform.parent.TryGetComponent(out ParticleHolder ph) ? ph : null; }
        if (ps == null) { ps = transform.TryGetComponent(out ParticleSystem s) ? s : null; }
    }


    Coroutine CO_ParticleIsPlaying;
    public void PlayParticles()
    {
        if (CO_ParticleIsPlaying != null) return;
        ps.Play();
        CO_ParticleIsPlaying = StartCoroutine(ParticleIsPlaying());
    }

    IEnumerator ParticleIsPlaying()
    {
        while (ps.isPlaying)
        {
            yield return null;
        }
        CO_ParticleIsPlaying = null;
        if (holder == null) { yield break; }
        holder.OnParticleDonePlaying();
        gameObject.SetActive(false);
        yield break;
    }


}
