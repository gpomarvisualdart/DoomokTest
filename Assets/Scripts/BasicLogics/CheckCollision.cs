using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class CheckCollision : MonoBehaviour
{
    Rigidbody rb;
    [SerializeField] CapsuleCollider collid;


    private void OnEnable()
    {
        if (rb == null || collid == null)
        {
            rb = GetComponent<Rigidbody>();
            collid = GetComponent<CapsuleCollider>();
        }
    }


    public bool CollisionChecker()
    {
        //Debug.Log(transform.position + rb.velocity);
        Vector3 direction = rb.velocity.normalized;
        return RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + (collid.center / 2f), transform.position + Vector3.up * collid.height, collid.radius + 0.01f, direction, rb.velocity.magnitude * Time.fixedDeltaTime, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.None);
    }


    private void FixedUpdate()
    {
        CollisionChecker();
    }

}
