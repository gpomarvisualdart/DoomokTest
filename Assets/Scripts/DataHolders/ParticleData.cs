using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ParticleData
{


    public struct ParticleRequestParams
    {
        public ParticleTypes type;
        public Vector3 pos;
        public Vector3 rot;
        public Vector3 scale;
        public Transform parent;
        public bool isParent;

        public ParticleRequestParams(ParticleTypes requestedType, Vector3 position, Vector3 rotation, Vector3 scale, Transform parent, bool isParent)
        {
            this.type = requestedType;
            this.pos = position;
            this.rot = rotation;
            this.scale = scale;
            this.parent = parent;
            this.isParent = isParent;
        }
    }
}


public enum ParticleTypes
{
    SLASH,
    BLOODHIT,
}


public static class ParticleIndexes
{
    public readonly static Dictionary<ParticleTypes, int> chosenParticleType = new Dictionary<ParticleTypes, int>()
    {
        { ParticleTypes.SLASH, 0 },
        {ParticleTypes.BLOODHIT, 1 },

    };
}
