using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BossHealthUIController : MonoBehaviour
{
    [SerializeField] Slider bossSlider;


    public void HealthChanged(float value)
    {
        bossSlider.value = value;
    }
}
