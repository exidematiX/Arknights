using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserTurret : Turret
{
    public float damagePerSecond = 60;
    public LineRenderer lineRenderer;
    public Transform laserStartPoint;
    
    public GameObject laserEffectGo;


    protected override void Attack()
    {
        Transform target = GetTarget();

        if (target == null)
        {
            laserEffectGo.SetActive(false);
            lineRenderer.enabled = false;
            return;
        }
        else
        {
            laserEffectGo.SetActive(true);
            laserEffectGo.transform.position = target.position;
            Vector3 lookAtPosition = transform.position;
            lookAtPosition.y = laserEffectGo.transform.position.y;
            laserEffectGo.transform.LookAt(lookAtPosition);
            target.GetComponent<Enemy>().TakeDamage(damagePerSecond * Time.deltaTime);
            lineRenderer.enabled = true;
            lineRenderer.SetPosition(0, laserStartPoint.position);
            lineRenderer.SetPosition(1, target.position);
        }

        

    }
}
