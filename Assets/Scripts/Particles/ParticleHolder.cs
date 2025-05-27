using ParticleData;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleHolder : MonoBehaviour
{
    ParticleSystem ps;
    ParticleRequestParams currentParams;

    public void InitializeParticleHolder(ParticleRequestParams prp)
    {
        if (transform.childCount < 1 || transform.childCount > ParticleIndexes.chosenParticleType.Count || transform.childCount < ParticleIndexes.chosenParticleType.Count) { Debug.LogError($"Invalid particle count for {this.name}!!"); return; }

        if (prp.isParent) transform.SetParent(prp.parent);
        transform.position = prp.pos;
        transform.localRotation = Quaternion.Euler(prp.rot);
        transform.localScale = prp.scale;

        if (!ParticleIndexes.chosenParticleType.TryGetValue(prp.type, out int value)) { OnParticleDonePlaying();  return; }
        if (!transform.GetChild(value).transform.TryGetComponent(out ParticleObjectController poc)) { OnParticleDonePlaying(); return; }
        transform.GetChild(value).gameObject.SetActive(true);
        poc.PlayParticles();
    }

    public void OnParticleDonePlaying()
    {
        transform.SetParent(ParticlesVFXManager.instance.GetTransform());
        gameObject.SetActive(false);
    }
}
