using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turret : MonoBehaviour
{
    public List<GameObject> enemyList = new List<GameObject>();


    public GameObject bulletPrefab;
    public Transform bulletPosition;
    public float attackRate = 1;
    private float nextAttackTime;// Time.time

    private Transform head;

    protected virtual void Start()
    {
        head = transform.Find("Head");
    }


    private void Update()
    {
        DirectionControl();
        Attack();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Enemy")
        {
            enemyList.Add(other.gameObject);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Enemy")
        {
            enemyList.Remove(other.gameObject);
        }
    }

    protected virtual void Attack()
    {
        if (enemyList == null || enemyList.Count == 0) return;
        //GameObject go = ;

        if (Time.time > nextAttackTime)
        {
            Transform target = GetTarget();
            if (target != null)
            {
                GameObject go = GameObject.Instantiate(bulletPrefab, bulletPosition.position, Quaternion.identity);
                go.GetComponent<Bullet>().SetTarget(target);
                nextAttackTime = Time.time + attackRate;
            }
            
        }
    }

    public Transform GetTarget()
    {
        if(enemyList!=null && enemyList.Count > 0 && enemyList[0] != null)
        {
            return enemyList[0].transform;
        }
        if (enemyList == null || enemyList.Count == 0) return null;

        List<int> indexList = new List<int>();
        for(int i = 0; i < enemyList.Count; i++)
        {
            if (enemyList[i] == null || enemyList[i].Equals(null))
            {
                indexList.Add(i);
            }
        }
        for(int i = indexList.Count - 1; i >= 0; i--)
        {
            enemyList.RemoveAt(indexList[i]);
        }
        if(enemyList!=null && enemyList.Count != 0)
        {
            return enemyList[0].transform;
        }
        return null;

    }
    private void DirectionControl()
    {
        Transform target = GetTarget();
        if (target == null) return;

        Vector3 targetPosition = target.position;
        targetPosition.y = head.position.y;

        head.LookAt(targetPosition);
    }
}
