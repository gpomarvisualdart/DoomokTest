using ProjectilePoolObject;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

public class ProjectilePoolManager : MonoBehaviour
{
    public static ProjectilePoolManager instance;


    private void Awake()
    {
        if (instance != null) return;
        instance = this;
    }



    public void GetProjectile(ProjectilePoolObject.ProjectileStat stats, ProjectileCapsuleColliderStat colliderStat, GameObject prfb)
    {
        if (transform.childCount < 1)  return;
        for (int i = 0; i < transform.childCount; i++)
        {
            Transform child = transform.GetChild(i);
            if (child.gameObject.activeInHierarchy) continue;
            if (!child.TryGetComponent(out LogicProjectile lp)) continue;

            CapsuleCollider cld = child.transform.AddComponent<CapsuleCollider>();
            cld.center = colliderStat.colliderCenter;
            cld.radius = colliderStat.radius;
            cld.height = colliderStat.height;
            cld.excludeLayers = ~colliderStat.collisionLayers;
            cld.isTrigger = colliderStat.isTrigger;

            child.gameObject.SetActive(true);
            lp.InitializeProjectile(stats, colliderStat, prfb);
            return;
        }

        Debug.Log("Every object is being used!");
    }
}
