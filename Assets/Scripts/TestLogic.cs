using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestLogic : MonoBehaviour
{
    InputManager iM;
    EntityCapsulePhysicsController entCapPhys;

    [SerializeField] float jumpHeight = 2.75f;

    bool isDashing = false;

    void OnEnable()
    {
        while (iM == null)
        {
            iM = FindObjectOfType<InputManager>();
            iM.enabled = true;
            iM.JumpEventSender += JumpEventReceiver;
            iM.DashEventSender += DashEventReceiver;
        }

        if(entCapPhys == null) entCapPhys = TryGetComponent(out EntityCapsulePhysicsController pc) ? pc : null;
    }


    private void FixedUpdate()
    {
        LogicMovement();
    }


    private void JumpEventReceiver(object sender, System.EventArgs e)
    {
        if (isDashing && CO_StartDashing != null) { isDashing = false; } 
        entCapPhys.currentGravity = -50f;
        float jumpVel = Mathf.Sqrt(2 * -entCapPhys.currentGravity * jumpHeight);
        entCapPhys.currentVelocity.y = jumpVel;
    }


    private void LogicMovement()
    {
        if (isDashing == true) return;
        entCapPhys.currentVelocity.x = iM.GetMovementAxis().x * 6f;
        Vector3 dir = transform.position + entCapPhys.currentVelocity;
        Vector3 lookDir = new Vector3(dir.x, transform.position.y, dir.z);
        transform.LookAt(lookDir);
        Debug.Log(transform.forward);
    }


    Coroutine CO_StartDashing;
    private void DashEventReceiver(object sender, System.EventArgs e)
    {
        if (CO_StartDashing != null) return;
        CO_StartDashing = StartCoroutine(StartDashing());
        isDashing = true;
    }

    IEnumerator StartDashing()
    {
        var flt_Count = 0f;
        var flt_MaxDuration = 0.4f;
        var b_doneDashing = false;

        while (flt_Count < flt_MaxDuration)
        {
            if (flt_Count < 0.2f && isDashing) 
            {
                Vector3 dir = transform.position + entCapPhys.currentVelocity;
                Vector3 lookDir = new Vector3(dir.x, transform.position.y, transform.position.z);
                transform.LookAt(lookDir);
                entCapPhys.currentVelocity = transform.forward * 30f; 
            }

            if (flt_Count > 0.2f && isDashing) { b_doneDashing = true; isDashing = false; }
            flt_Count += Time.deltaTime;
            yield return null;
        }
        CO_StartDashing = null;
    }
}
