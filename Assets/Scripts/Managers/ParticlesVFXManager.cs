using ParticleData;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticlesVFXManager : MonoBehaviour
{
    public static ParticlesVFXManager instance;
    public Transform GetTransform() { return transform; }


    private void Awake()
    {
        if (instance != null) return;
        instance = this;
    }


    public void RequestParticleVFX(ParticleRequestParams prp)
    {
        if (transform.childCount < 1) return;
        for (int i = 0; i < transform.childCount; i++)
        {
            Transform child = transform.GetChild(i);
            if (child.gameObject.activeInHierarchy) continue;
            if (!child.TryGetComponent(out ParticleHolder pc)) return;
            child.gameObject.SetActive(true);
            pc.InitializeParticleHolder(prp);
            return;
        }

        Debug.LogWarning("All particles are being used!");
    }
}
