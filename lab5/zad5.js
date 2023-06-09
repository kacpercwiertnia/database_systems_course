const database = "KC"
const collection = 'students'

use (database);

db.createCollection (collection);

db.getCollection (collection).insertMany(
[{  name: "Jan",
    surname: "Kowalski",
    age: 15,
    subjects: [
    {   name: "Biology",
        ects: 3,
        marks: [2, 6, 2, 4]
    },
    {   name: "Physics",
        ects: 5,
        marks: [3, 5, 3, 2]
    }]
 },
 {  name: "Mateusz",
    surname: "Nowak",
    age: 16,
    subjects: [
    {   name: "Mathematics",
        ects: 3,
        marks: [6, 4, 1, 1]
    },
    {   name: "Physics",
        ects: 5,
        marks: [5, 2, 3, 2]
    }]
 }])

db.getCollection(collection).deleteOne(
    {   name: "Mateusz",
        surname: "Nowak",
        age: 16,
        subjects: [
    {   name: "Mathematics",
        ects: 3,
        marks: [6, 4, 1, 1]
    },
    {   name: "Physics",
        ects: 5,
        marks: [5, 2, 3, 2]
    }]}
)

use('KC');

db.getCollection('students').updateOne(
{   name: "Jan",
    surname: "Kowalski",
    age: 15,
    subjects: [{    name: "Biology",
                    ects: 3,
                    marks: [2, 6, 2, 4]
                },
                {
                    name: "Physics",
                    ects: 5,
                    marks: [ 3, 5, 3, 2] }
            ]
},
{
    $set:{name: "Arkadiusz"}
});

db.getCollection('students').find({name:"Arkadiusz"})