db = db.getSiblingDB("dashboarddb");

db.createUser({
  user: "dashboarduser",
  pwd: "dashboardpass",
  "roles": [
    {
      "role": "readWrite",
      "db": "dashboarddb"
    }
  ]
});