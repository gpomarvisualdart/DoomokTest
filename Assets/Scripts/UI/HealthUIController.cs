using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthUIController : MonoBehaviour
{
    [SerializeField] Slider healthSlider;

    public void ChangeHealthUIValue(float value)
    {
        healthSlider.value = value;
    }
}
