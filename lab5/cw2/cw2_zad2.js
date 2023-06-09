// ZADANIE 2
// przykład b wariant 1
// struktura składa się z 3 kolekcji: firmy, wycieczki, uzytkownicy. Firmy mają id wycieczek organizowanych przez nich, wycieczki mają recenzje wraz z id uzytkownikow, a uzytkownicy maja id wycieczek, na ktorych byli.

use('travel');

db.createCollection('company');
db.createCollection('trip');
db.createCollection('user');

db.getCollection('company').insertMany([
    {
        business_id: 0,
        name: "itaka",
        address: "45-072 Opole ul. Reymonta 39",
        trips: [{trip_id: 0},
                {trip_id: 2},
                {trip_id: 3},
                {trip_id: 6}]
    },
    {
        business_id: 1,
        name: "r",
        address: "90-361 Łódź ul. Piotrkowska 270",
        trips: [{trip_id: 1},
                {trip_id: 2},
                {trip_id: 4},
                {trip_id: 5}]
    },
    {
        business_id: 2,
        name: "tui",
        address: "02-675 Warszawa ul. Wołoska 22a",
        trips: [{trip_id: 0},
                {trip_id: 1},
                {trip_id: 2},
                {trip_id: 3}]
    },
])

db.getCollection('trip').insertMany([
    {
        trip_id: 0,
        name: "Whala!Bavaro",
        country: "Dominikana",
        reviews: [{user_id: 0, stars: 3, comment: "Tak średnio bym powiedział"},
                  {user_id: 3, stars: 4, comment: "Ok"}]
    },
    {
        trip_id: 1,
        name: "Rixos Sungate",
        country: "Turcja",
        reviews: [{user_id: 2, stars: 2, comment: "Słabo"},
                  {user_id: 1, stars: 1, comment: "Dramat"}]
    },
    {
        trip_id: 2,
        name: "Saint Nicholas",
        country: "Grecja",
        reviews: [{user_id: 1, stars: 5, comment: "Super"},
                  {user_id: 0, stars: 4, comment: "Git"}]
    },
    {
        trip_id: 3,
        name: "Nest Style Zanzibar",
        country: "Zanzibar",
        reviews: [{user_id: 1, stars: 5, comment: "Piękne miejsce"},
                  {user_id: 3, stars: 2, comment: "Straszne miejsce"}]
    },
    {
        trip_id: 4,
        name: "Koggala Beach",
        country: "Sri Lanka",
        reviews: [{user_id: 2, stars: 2, comment: "Brzydko"},
                  {user_id: 3, stars: 3, comment: "Moze być"}]
    },
    {
        trip_id: 5,
        name: "Plaza Real",
        country: "Algarve",
        reviews: [{user_id: 2, stars: 2, comment: "Nie mój klimat"},
                  {user_id: 0, stars: 2, comment: "Słabo"}]
    },
    {
        trip_id: 6,
        name: "Port de Soller",
        country: "Majorka",
        reviews: [{user_id: 2, stars: 3, comment: "Tak średnio bym powiedział"},
                  {user_id: 3, stars: 4, comment: "Ok"}]
    },
])

db.getCollection('user').insertMany([
    {   user_id: 0,
        name: "Jan",
        surname: "Nowak",
        trips: [{trip_id: 0},
                {trip_id: 2},
                {trip_id: 5}]
    },
    {   user_id: 1,
        name: "Marek",
        surname: "Kowalski",
        trips: [{trip_id: 1},
                {trip_id: 2},
                {trip_id: 3}]
    },
    {   user_id: 2,
        name: "Janusz",
        surname: "Jop",
        trips: [{trip_id: 1},
                {trip_id: 4},
                {trip_id: 5},
                {trip_id: 6}]
    },
    {   user_id: 3,
        name: "Anna",
        surname: "Polak",
        trips: [{trip_id: 0},
                {trip_id: 3},
                {trip_id: 4},
                {trip_id: 6}]
    },
])

// Zapytania do 1 wariantu

db.getCollection('company')
    .find({
        address: {$regex: 'Warszawa'}
    })

db.getCollection('company')
    .aggregate([
        {$lookup: {
          from: 'trip',
          localField: 'trips.trip_id',
          foreignField: 'trip_id',
          as: 'trips_info'
        }},
        {$project:{
            _id: 0,
            name: 1,
            trips_info: 1
        }}
    ])

db.getCollection('trip')
    .find({
        "reviews.user_id": 0
    })


db.getCollection('trip')
    .aggregate([
        {$project:{
            _id: 0,
            name: 1,
            avgStars: { $avg: "$reviews.stars" }
        }},
    ])

db.getCollection('user')
    .find({
        surname: {$regex: 'owa'}
    })


db.getCollection('user')
    .aggregate([
        {$lookup: {
            from: 'trip',
            localField: 'trips.trip_id',
            foreignField: 'trip_id',
            as: 'trips_info'
        }},
        {$project: {
            _id: 0,
            name: 1,
            surname: 1,
            trips: "$trips_info.name"
        }},
    ])

// wariant 2
// struktura podobna do wariantu 1 lecz recenzje teraz maja osobną kolekcję

use('travel2');

db.createCollection('company');
db.createCollection('trip');
db.createCollection('user');
db.createCollection('review');

db.getCollection('company').insertMany([
    {
        business_id: 0,
        name: "itaka",
        address: "45-072 Opole ul. Reymonta 39",
        trips: [{trip_id: 0},
                {trip_id: 2},
                {trip_id: 3},
                {trip_id: 6}]
    },
    {
        business_id: 1,
        name: "r",
        address: "90-361 Łódź ul. Piotrkowska 270",
        trips: [{trip_id: 1},
                {trip_id: 2},
                {trip_id: 4},
                {trip_id: 5}]
    },
    {
        business_id: 2,
        name: "tui",
        address: "02-675 Warszawa ul. Wołoska 22a",
        trips: [{trip_id: 0},
                {trip_id: 1},
                {trip_id: 2},
                {trip_id: 3}]
    },
])

db.getCollection('trip').insertMany([
    {
        trip_id: 0,
        name: "Whala!Bavaro",
        country: "Dominikana",
        reviews: [{review_id: 0},
                  {review_id: 1}]
    },
    {
        trip_id: 1,
        name: "Rixos Sungate",
        country: "Turcja",
        reviews: [{review_id: 2},
                  {review_id: 3}]
    },
    {
        trip_id: 2,
        name: "Saint Nicholas",
        country: "Grecja",
        reviews: [{review_id: 4},
                  {review_id: 5}]
    },
    {
        trip_id: 3,
        name: "Nest Style Zanzibar",
        country: "Zanzibar",
        reviews: [{review_id: 6},
                  {review_id: 7}]
    },
    {
        trip_id: 4,
        name: "Koggala Beach",
        country: "Sri Lanka",
        reviews: [{review_id: 8},
                  {review_id: 9}]
    },
    {
        trip_id: 5,
        name: "Plaza Real",
        country: "Algarve",
        reviews: [{review_id: 10},
                  {review_id: 11}]
    },
    {
        trip_id: 6,
        name: "Port de Soller",
        country: "Majorka",
        reviews: [{review_id: 12},
                  {review_id: 13}]
    },
])

db.getCollection('user').insertMany([
    {   user_id: 0,
        name: "Jan",
        surname: "Nowak",
        trips: [{trip_id: 0},
                {trip_id: 2},
                {trip_id: 5}]
    },
    {   user_id: 1,
        name: "Marek",
        surname: "Kowalski",
        trips: [{trip_id: 1},
                {trip_id: 2},
                {trip_id: 3}]
    },
    {   user_id: 2,
        name: "Janusz",
        surname: "Jop",
        trips: [{trip_id: 1},
                {trip_id: 4},
                {trip_id: 5},
                {trip_id: 6}]
    },
    {   user_id: 3,
        name: "Anna",
        surname: "Polak",
        trips: [{trip_id: 0},
                {trip_id: 3},
                {trip_id: 4},
                {trip_id: 6}]
    },
])

db.getCollection('review').insertMany([
    {review_id: 0, trip_id: 0, user_id: 0, stars: 3, comment: "Tak średnio bym powiedział"},
    {review_id: 1, trip_id: 0, user_id: 3, stars: 4, comment: "Ok"},
    {review_id: 2, trip_id: 1, user_id: 2, stars: 2, comment: "Słabo"},
    {review_id: 3, trip_id: 1, user_id: 1, stars: 1, comment: "Dramat"},
    {review_id: 4, trip_id: 2, user_id: 1, stars: 5, comment: "Super"},
    {review_id: 5, trip_id: 2, user_id: 0, stars: 4, comment: "Git"},
    {review_id: 6, trip_id: 3, user_id: 1, stars: 5, comment: "Piękne miejsce"},
    {review_id: 7, trip_id: 3, user_id: 3, stars: 2, comment: "Straszne miejsce"},
    {review_id: 8, trip_id: 4, user_id: 2, stars: 2, comment: "Brzydko"},
    {review_id: 9, trip_id: 4, user_id: 3, stars: 3, comment: "Moze być"},
    {review_id: 10, trip_id: 5, user_id: 2, stars: 2, comment: "Nie mój klimat"},
    {review_id: 11, trip_id: 5, user_id: 0, stars: 2, comment: "Słabo"},
    {review_id: 12, trip_id: 6, user_id: 2, stars: 3, comment: "Tak średnio bym powiedział"},
    {review_id: 13, trip_id: 6, user_id: 3, stars: 4, comment: "Ok"}
])

// Zapytania do warianru 2

db.getCollection('user')
    .aggregate([
        {$lookup: {
          from: 'review',
          localField: 'user_id',
          foreignField: 'user_id',
          as: 'reviews'
        }},
        {$project: {
          _id: 0,
          name: 1,
          surname: 1,
          reviews: 1
        }}
    ])