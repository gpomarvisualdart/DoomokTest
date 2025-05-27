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
        ApplyVelocity();
        ApplyGravity();
    }


    private void ApplyVelocity()
    {
        currentVelocity = Vector3.ClampMagnitude(currentVelocity, maxSpeed);
        if (IsColliding()) return;
        transform.position += currentVelocity * Time.fixedDeltaTime; 
    }


    private bool IsColliding()
    {
        return RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, currentVelocity, currentVelocity.magnitude * Time.fixedDeltaTime, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);
    }


    private bool GroundCheck()
    {
        if (currentVelocity.y == 0f)
        {
            return RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, Vector3.down, 0.01f, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);
        }
        else
        {
            return RotaryHeart.Lib.PhysicsExtension.Physics.CapsuleCast(transform.position + pointOne, transform.position + pointTwo, radius, Vector3.down, currentVelocity.magnitude * Time.fixedDeltaTime, RotaryHeart.Lib.PhysicsExtension.PreviewCondition.Both);
        }
    }


    private void ApplyGravity()
    {
        Debug.Log(GroundCheck());
        if(!GroundCheck() )
        {
            currentVelocity.y += currentGravity * Time.fixedDeltaTime;
        }
        else
        {
            currentVelocity.y = 0f;
            currentGravity = defaultGravity;
        }
    }

    //Tapi bisa gak kita hanya pakai satu function untuk check collision ditambah ground check? Jadi hanya menggunakan satu capsulecast doang. Soalnya kalau misalkan kita pakai dua function untuk detect ground dan collision, ini akan bermasalah. Contoh misalkan kita lompat, karena ada dua function yang cek ground dan collision dan mereka menggunakan rumus maxDistance yang sama yaitu currentVelocity.magnitude * Time.fixedDeltaTime
}
