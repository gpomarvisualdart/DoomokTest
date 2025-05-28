using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleObjectController : MonoBehaviour
{
    ParticleHolder holder;
    ParticleSystem ps;
    float lifeTime;

    private void OnEnable()
    {
        if (holder == null) { holder = transform.parent.TryGetComponent(out ParticleHolder ph) ? ph : null; }
        if (ps == null) { ps = transform.TryGetComponent(out ParticleSystem s) ? s : null; }
    }


    Coroutine CO_ParticleIsPlaying;
    public void PlayParticles()
    {
        if (CO_ParticleIsPlaying != null) return;
        lifeTime = ps.main.duration + ps.main.startLifetime.constantMax;
        ps.Play();
        CO_ParticleIsPlaying = StartCoroutine(ParticleIsPlaying());
    }

    IEnumerator ParticleIsPlaying()
    {
        float count = 0f;
        while ( count <= lifeTime)
        {
            count += Time.deltaTime;
            yield return null;
        }
        CO_ParticleIsPlaying = null;
        if (holder == null) { yield break; }
        holder.OnParticleDonePlaying();
        gameObject.SetActive(false);
        yield break;
    }


}
