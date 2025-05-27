using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthController : MonoBehaviour, IEntityHealthController
{
    [SerializeField] float maxHealth;
    [SerializeField] float currentHealth;
    public float GetCurrentHealth() { return currentHealth;}

    private void OnEnable()
    {
        HealthChange(maxHealth);
    }


    public void HealthChange(float value)
    {
        currentHealth += value;
        if (currentHealth < 0) currentHealth = 0;
        else if (currentHealth > maxHealth) currentHealth = maxHealth;

        UIManager.instance.HealthChanged(currentHealth);
    }
}
