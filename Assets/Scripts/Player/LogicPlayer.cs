using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LogicPlayer : MonoBehaviour
{
    InputManager inputManager;
    Rigidbody rb;
    PlayerStates currentState;

    int numOfJumpsMidAir = 1;
    int playerLayer;
    int enemyLayer;

    public Transform GetPlayerTransform() {  return transform; }

    private void OnEnable()
    {
        while (inputManager == null)
        {
            inputManager = FindObjectOfType<InputManager>();
        }
        inputManager.AttackEventSender += AttackEventReceiver;
        inputManager.JumpEventSender += JumpEventReceiver;
        inputManager.DashEventSender += DashEventReceiver;

        rb = GetComponent<Rigidbody>();
        playerLayer = LayerMask.NameToLayer("Player");
        enemyLayer = LayerMask.NameToLayer("Enemies");

        Debug.Log($"Player Layer: {playerLayer} | Enemy Layer: {enemyLayer}");
    }


    private void OnDisable()
    {
        if (inputManager != null)
        {
            inputManager.AttackEventSender -= AttackEventReceiver;
            inputManager.JumpEventSender -= JumpEventReceiver;
            inputManager.DashEventSender -= DashEventReceiver;
        }
    }




    private void JumpEventReceiver(object sender, System.EventArgs e)
    {
        if (numOfJumpsMidAir < 1) return;
        if (CO_EarlyJumpBoost != null) StopCoroutine(CO_EarlyJumpBoost);
        numOfJumpsMidAir--;
        rb.velocity = new Vector3(rb.velocity.x, 0, rb.velocity.z);
        CO_EarlyJumpBoost = StartCoroutine(EarlyJumpBoost());
    }
    Coroutine CO_EarlyJumpBoost;
    IEnumerator EarlyJumpBoost()
    {
        var flt_count = 0f;
        var flt_time = 0.2f;
        rb.velocity += new Vector3(0f, 5f, 0f);
        while (flt_count < flt_time)
        {
            rb.velocity += new Vector3(0f, 0.27f, 0f);
            flt_count += Time.deltaTime;
            yield return null;
        }
        rb.velocity = new Vector3(rb.velocity.x, 2.5f, rb.velocity.z);
        CO_EarlyJumpBoost = null;
    }


    private void AttackEventReceiver(object sender, System.EventArgs e)
    {
        Debug.Log("Attacked!");
    }


    private void DashEventReceiver(object sender, System.EventArgs e)
    {
        if (currentState == PlayerStates.Dashing || CO_Dashing != null) return;
        currentState = PlayerStates.Dashing;
        CO_Dashing = StartCoroutine(DashDuration());
    }

    Coroutine CO_Dashing; 
    IEnumerator DashDuration()
    {
        Physics.IgnoreLayerCollision(playerLayer, enemyLayer, true);
        
        var flt_Count = 0f;
        var flt_Length = 1f;
        while (flt_Count < flt_Length)
        {
            if (flt_Count < 0.27f) rb.MovePosition(transform.position + transform.forward * 200f * Time.deltaTime);
            if (flt_Count > 0.27f) currentState = PlayerStates.Idle;
            if (flt_Count > 0.5f) Physics.IgnoreLayerCollision(playerLayer, enemyLayer, false);
            flt_Count += Time.deltaTime;
            yield return null;
        }
        CO_Dashing = null;
    }


    private void Movement()
    {
        if (currentState == PlayerStates.Dashing) return;
        var vect2_MoveDir = inputManager.GetMovementAxis();
        var vect3_MoveDir = new Vector3(vect2_MoveDir.x, 0, 0);
        rb.MovePosition(rb.position + vect3_MoveDir * 6.5f * Time.fixedDeltaTime);
        if (vect3_MoveDir == Vector3.zero) return;
        Vector3 lookDir = new Vector3 (transform.position.x + vect3_MoveDir.x, transform.position.y, transform.position.z);
        transform.LookAt(lookDir);

    }


    private void GroundCheck()
    {
        bool onGround = Physics.Raycast((transform.position + transform.up), Vector3.down, 1.1f);
        if (onGround)
        {
            numOfJumpsMidAir = 1;
        }
    }


    // Update is called once per frame
    void Update()
    {
         GroundCheck();
    }

    private void FixedUpdate()
    {
        Movement();
    }

}
