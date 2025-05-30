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

    public float currentDrag = 0f;
    public float dragThreshold = 0.1f;

    [SerializeField] float defaultGravity = -9.81f;
    public float currentGravity = -9.81f;
    public LayerMask collisionLayers;
    [SerializeField] private LayerMask _defaultCollisionLayers;
    public LayerMask defaultcollisionLayers { get => _defaultCollisionLayers; private set => _defaultCollisionLayers = value; }
    [SerializeField] RotaryHeart.Lib.PhysicsExtension.PreviewCondition debugType;


    private void OnEnable()
    {
        collisionLayers = defaultcollisionLayers;
    }


    private void FixedUpdate()
    {
        GroundCheck();
        ApplyVelocity();
        ApplyGravity();
    }


    private void ApplyVelocity()
    {
        currentVelocity = Vector3.ClampMagnitude(currentVelocity, maxSpeed);
        RaycastHit hit;
        bool collided = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, currentVelocity, out hit, currentVelocity.magnitude * Time.fixedDeltaTime, collisionLayers, debugType);
        if (collided)
        {
            Debug.Log(hit.transform.name);
            if (currentVelocity.x != 0)
            {
                Vector3 xDir = new Vector3(currentVelocity.x, 0f, 0f);
                collided = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, xDir, out hit, currentVelocity.magnitude * Time.fixedDeltaTime, collisionLayers, debugType);
                if (collided) { currentVelocity.x = 0f; Debug.Log($"{hit.transform.gameObject.layer} from {hit.transform.name} with {LayerMask.NameToLayer("Enemies")} and current layer value is {collisionLayers.value}");}

            }
            if (currentVelocity.y != 0)
            {
                Vector3 yDir = new Vector3(0f, currentVelocity.y, 0f);
                collided = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, yDir, out hit, currentVelocity.magnitude * Time.fixedDeltaTime, collisionLayers, debugType);
                if (collided && Vector3.Dot(hit.normal, Vector3.up) > 0.3f) { currentVelocity.y = 0f; legOnGround = true; currentGravity = defaultGravity;  }
            }
        }

        if (Mathf.Abs(currentVelocity.x) > 0f)
        {
            if (Mathf.Abs(currentVelocity.x) > dragThreshold && dragThreshold != 0f)
            {
                currentVelocity.x -= currentVelocity.x * currentDrag * Time.fixedDeltaTime;
                if (Mathf.Abs(currentVelocity.x) < 0.01f) currentVelocity.x = 0f;
            }
        }

        transform.position += currentVelocity * Time.fixedDeltaTime; 
    }



    bool legOnGround;
    private void GroundCheck()
    {
        if (!legOnGround) return;

        bool onGround = RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, Vector3.down, 0.01f, collisionLayers, debugType);

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
