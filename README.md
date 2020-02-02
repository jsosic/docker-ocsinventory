docker-ocsinventory
===================

Dockerized [OCSInventory Server](https://github.com/OCSInventory-NG/OCSInventory-Server).


## Rationale

Although there is already an [official image](https://hub.docker.com/r/ocsinventory/ocsinventory-docker-image)
for OCS Inventory Server, it's deviating from Docker's [best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/),
and can pose a challenge to run in a production environment.

Major problem with the state of the original image [at the time of the writing](https://github.com/OCSInventory-NG/OCSInventory-Docker-Image/blob/1a227c3df71120a56ce6d377704c26fcef34097f/2.6/Dockerfile)
of this document is that it installs OCS upon the initial start of the container, as seen in the [entrypoint](https://github.com/OCSInventory-NG/OCSInventory-Docker-Image/blob/1a227c3df71120a56ce6d377704c26fcef34097f/2.6/scripts/docker-entrypoint.sh)
script.

This is making it very hard to extend this image in any sensible way.

Motivation behind this project is to provide an image that's not suffering from the same flaws as the official one.

## Pulling image

```
docker pull jsosic/ocsinventory:2.6
```

## Building image

```
make build
```

## Running image

The container accepts the following environment variables:

- `OCS_DBSERVER_WRITE` - MySQL master host - the one which can accept write queries.
- `OCS_DBSERVER_READ` - MySQL slave host, where read queries will be sent. It can be master.
- `OCS_DBNAME` - MySQL database name. Defaults to `ocsweb`.
- `OCS_DBUSER` - MySQL user. Defaults to `ocs`.
- `OCS_DBPASS` - MySQL user password.

**Note**: MySQL is expected to run on port 3306. This image doesn't currently support custom port number.


## Dependencies

### Install MySQL

Any kind of MySQL server is supported: no matter the locally installed, remote MySQL or a docker one.

Once you have a MySQL up and running, creating a database and adding a user is a neccessity:

```
sudo -u postgres createuser ocs
sudo -u postgres createdb ocsweb -O ocs
sudo -u postgres psql -c "ALTER USER ocs SET PASSWORD TO 'super_secret'"
```

## Upgrading

Upgrading to a new OCS Inventory is as simple as pulling and running the latest image (or use a specific tag).
Once you open the `/ocsreports` URI, an option to run the database upgrade will be presented.


## Known issues

This container runs apache2, which may be considered suboptimal, but is the most convenient way to run OCS.
