using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthController : MonoBehaviour, IEntityHealthController
{
    [SerializeField] float maxHealth;
    [SerializeField] float currentHealth;
    public float GetCurrentHealth() { return currentHealth;}


    public void HealthChange(float value)
    {
        currentHealth += value;
        UIManager.instance.HealthChanged(currentHealth);
    }
}
