using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices.WindowsRuntime;
using UnityEngine;

public class InputManager : MonoBehaviour
{
    PlayerInput input;

    private void OnEnable()
    {
        input = new PlayerInput();
        input.Gameplay.Enable();
        input.Gameplay.Attack.performed += AttackReceiver;
        input.Gameplay.Jump.performed += JumpReceiver;
        input.Gameplay.Dash.performed += DashReceiver;
    }


    private void OnDisable()
    {
        if (input != null)
        {
            input.Gameplay.Disable();
            input.Gameplay.Attack.performed -= AttackReceiver;
            input.Gameplay.Jump.performed -= JumpReceiver;
        }
    }






    public event EventHandler AttackEventSender;
    private void AttackReceiver(UnityEngine.InputSystem.InputAction.CallbackContext obj)
    {
        AttackEventSender.Invoke(this, EventArgs.Empty);
    }


    public event EventHandler JumpEventSender;
    private void JumpReceiver(UnityEngine.InputSystem.InputAction.CallbackContext obj)
    {
        JumpEventSender?.Invoke(this, EventArgs.Empty);
    }


    public event EventHandler DashEventSender;
    private void DashReceiver(UnityEngine.InputSystem.InputAction.CallbackContext obj)
    {
        DashEventSender?.Invoke(this, EventArgs.Empty);
    }


    public Vector2 GetMovementAxis()
    {
        if (input.Gameplay.MovementArrows.ReadValue<Vector2>() != Vector2.zero)
        {
            return input.Gameplay.MovementArrows.ReadValue<Vector2>();
        }
        else
        {
            return input.Gameplay.MovementKeyboard.ReadValue<Vector2>();
        }
    }
}
