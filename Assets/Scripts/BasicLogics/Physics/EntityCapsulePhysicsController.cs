using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EntityCapsulePhysicsController : MonoBehaviour
{
    public Vector3 currentVelocity;
    [SerializeField] Vector3 pointOne;
    [SerializeField] Vector3 pointTwo;
    [SerializeField] float radius;
    [SerializeField] float maxSpeed = 50f;

    [SerializeField] float defaultGravity = -9.81f;
    public float currentGravity = -9.81f;

    private void FixedUpdate()
    {
        GroundCheck();
        ApplyVelocity();
        ApplyGravity();
    }


    private void ApplyVelocity()
    {
        currentVelocity = Vector3.ClampMagnitude(currentVelocity, maxSpeed);
        bool collided;
        /*if (currentVelocity.y != 0f)
        {
            collided = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, Vector3.down, currentVelocity.magnitude * Time.fixedDeltaTime, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);
            Debug.Log(collided);
            ApplyGravity(collided);
        }
        else if (currentVelocity.y == 0f)
        {
            collided = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, Vector3.down, 0.01f, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);
            Debug.Log(collided);
            ApplyGravity(collided);
        }*/

        Vector3 fixedVelocity = currentVelocity;

        collided = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, currentVelocity, currentVelocity.magnitude * Time.fixedDeltaTime, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);

        if (collided)
        {
            //bool collisionReChecks;
            if (currentVelocity.x != 0)
            {
                Vector3 xDir = new Vector3(currentVelocity.x, 0f, 0f);
                collided = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, xDir, currentVelocity.magnitude * Time.fixedDeltaTime, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);
                if (collided) currentVelocity.x = 0f;

            }
            if (currentVelocity.y != 0)
            {
                Vector3 yDir = new Vector3(0f, currentVelocity.y, 0f);
                collided = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, yDir, currentVelocity.magnitude * Time.fixedDeltaTime, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);
                if (collided && currentVelocity.y < 0f) { currentVelocity.y = 0f; legOnGround = true; currentGravity = defaultGravity; }
                else currentVelocity.y = 0f;
            }
        }

        transform.position += currentVelocity * Time.fixedDeltaTime; 
    }


    private bool IsColliding()
    {
        return RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, currentVelocity, currentVelocity.magnitude * Time.fixedDeltaTime, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);
    }


    bool legOnGround;
    private void GroundCheck()
    {
        if (!legOnGround) return;

        currentVelocity.y = 0f;
        bool onGround = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, Vector3.down, 0.01f, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);

        if (!onGround) legOnGround = false;
        
    }


    private void ApplyGravity()
    {
        if (!legOnGround)
        {
            currentVelocity.y += currentGravity * Time.fixedDeltaTime;
        }
    }
}
