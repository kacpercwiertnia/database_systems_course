package org.example;

import org.hibernate.Transaction;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;

public class MainJPA {

    public static void main(String[] args) {
        EntityManagerFactory emf = Persistence.createEntityManagerFactory("myDatabaseConfig");
        EntityManager em = emf.createEntityManager();
        EntityTransaction etx = em.getTransaction();
        etx.begin();
        Customer customer1 = new Customer("SuperZabawki", "Budryka", "Kraków", "32-512", 0.6);
        Customer customer2 = new Customer("AutaPolskie", "Czarnowiejska", "Gdynia", "38-322", 0.2);
        Supplier supplier1 = new Supplier("HurtZabawek", "Kamienna", "Warszawa", "30-322", "12312321321");
        Supplier supplier2 = new Supplier("EuroTrade", "Przemysłowa", "Bytom", "31-202", "123123678678");

        em.persist(customer1);
        em.persist(customer2);
        em.persist(supplier1);
        em.persist(supplier2);

        Supplier foundSupplier = (Supplier)em.find(Supplier.class, 3);
        System.out.println(foundSupplier.toString());

        Customer foundCustomer = (Customer) em.find(Customer.class, 1);
        System.out.println(foundCustomer.toString());

        etx.commit();
        em.close();
    }
}
