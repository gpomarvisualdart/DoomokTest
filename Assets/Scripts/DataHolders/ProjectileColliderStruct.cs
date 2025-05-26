using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace ProjectilePoolObject
{
    public struct ProjectileCapsuleColliderStat
    {
        public Vector3 colliderCenter;
        public float radius;
        public float height;
        public bool isTrigger;
        public int collisionLayers;

        public ProjectileCapsuleColliderStat(Vector3 center, float radius, float height, bool isTrigger, int layers)
        {
            this.colliderCenter = center;
            this.radius = radius;
            this.height = height;
            this.isTrigger = isTrigger;
            this.collisionLayers = layers;
        }
    }

    public struct ProjectileStat
    {
        public Transform caller;
        public Vector3 direction;
        public float duration;
        public float speed;
        public float damage;
        public float knockback;

        public ProjectileStat(Transform caller, Vector3 direction, float duration, float speed, float damage, float knockbackPower)
        {
            this.caller = caller;
            this.direction = direction;
            this.duration = duration;
            this.speed = speed;
            this.damage = damage;
            this.knockback = knockbackPower;
        }

    }

}
