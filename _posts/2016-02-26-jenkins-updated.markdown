---
layout: post
title:  "Jenkins: Updated"
date:   2016-02-26 17:09
categories: jenkins
author: "Michael Allen"
---

Last Friday we successfully deployed our Jenkins to a vm in the DSTL Tiberius
network. That deploy involved ssh-ing in to the vm and creating a set of secrets
that were specific to that location.

Since then the number of secrets needed has grown and so we have had to change
how we handle secrets. This means that the new update to jenkins is not as
straight forward as we would like.

This post lists the steps needed to update jenkins to it's latest version.

## New Secrets

** We might want to change this so that, as a set of instructions it reads from scratch rather than having already made some edits **

Secrets now live in `/opt/secrets` since we have more to deal with now. Our
secrets live in [dstl-lighthouse-secrets].

We'll talk about 2 boxes/servers in this guide:
  - the `deployer box` (the one with jenkins on it)
  - the `application box` (the one hosting the lighthouse application)

On the `deployer box` we need to:

- **Move existing secrets to `/opt/secrets`**
  - run `mkdir /opt/secrets`
  - then `mv /opt/ssh_rsa /opt/secrets`
  - then `mv /opt/ssh_rsa.pub /opt/secrets`
  - then `mv /opt/site_specific.yml /opt/secrets`

- **add a private key file to `/opt/secrets`**

        $> ssh-keygen
        Use: /opt/secrets/lighthouse.deploy
        
        $> ll /opt/secrets
        lighthouse.deploy
        lighthouse.deploy.pub

- **Change the permissions on this private key file**:
 
        $> chmod 600 /opt/secrets/lighthouse.deploy*

- **Copy over the public key to the `application box`**. This key needs access to the VM you intend to deploy lighthouse to. For this to work, you'll need to add the contents of the public key you've just created (lighthouse.deploy.pub) to `~/.ssh/authorized_keys` on the application box. Here's how:
  
        $> ssh-copy-id -i ~/.ssh/lighthouse.deploy.pub base@<`application box`>
  
- **SSH into the `application box`**:
  
        $> vim /etc/ssh/sshd_config

- **Make changes so that the following parameters look like this**:
  
        RSAAuthentication yes
        PubkeyAuthentication yes
        AuthorizedKeysFile  %h/.ssh/authorized_keys
        passwordAuthentication no
  
  (We have an example key `secrets/preview.deploy.pem` that we use for AWS deploy
  In the rest of this post I'll use `{lighthouse.pem}` to represent this key.)

  Set permissions for the directory and 'authorized_keys`:
  
        $> chmod 755 ~/.ssh
        $> chmod 600 ~/.ssh/authorized_keys

With those in place we can start modifying the `site_specific.yml` to add the
new settings that are required in by the new jobs.

- **add the following lines to `/opt/secrets/site_specific.yml`**
  - `jenkins_url: '{jenkins url or ip plus port}'`

      The url you want your jenkins to be at.

  - `github_api_url: 'https://api.github.com'`

      Always going to be github unless you proxy github.

  - `github_token: '8a571107dcf389459e5569c589a704b92be68d95'`

      Your github access token.

  - `jenkins_update_target: '--bronze'`

      Configures the update job to know what environment you are updating.
      (Could have been hostname based but we didn't know what hostnames would
      be used.)

  - `lighthouse_inventory_file: '/opt/secrets/bronze.inventory'`

      The location of your ansible inventory for lighthouse. Ours is in
      `secrets/preview.inventory`.
      We will place your file in `/opt/secrets/bronze.inventory`.

  - `lighthouse_ip: '{Your.lighthouse.ip}'`

      The IP of the VM you intend to deploy lighthouse to.

  - `lighthouse_port: '8080'`

      The IP of lighthouse. It is 8080, no matter what you like (because we
      haven't made it configurable yet).

  - `vault_password: 'redandwhitestriped'`

      The password to the vault in the Infrastructure repo. Needed to deploy
      lighthouse.

With all those done we now need to create a inventory that describes your VM

- **add a file `/opt/secrets/bronze.inventory`**


        [lighthouse-app-server]
        {your.lighthouse.ip} ansible_ssh_private_key_file=/opt/secrets/{lighthouse.pem} ansible_ssh_user={user}


    The `{user}` should have root priviledges on the box. Centos is common in AWS
    and vagrant in Vagrant images.

## The Update job

The Update Jenkins job has a few settings that we need to change to allow it to
checkout our secrets submodule and know what behavior the bootstrap script needs
to perform.

- **In Update Jenkins job add Recursive checkout submodules**

    - Go to the job
    - Click Configure
    - In Source Code Management click Additional Behaviors
    - Choose Advanced sub-modules behavior
    - Check Recursively update from the panel that appears

- **Change the run script**

    - In the Update Jenkins configure scroll down to the Build script
    - change `sudo ./bootstrap.sh` to `./bootstrap.sh --bronze`

## Run the update job

Finally we can trigger the job. Jenkins should update itself and add a few new
jobs to it's console.

## Deploy the app

All the lighthouse jobs are in a pipeline. If you trigger the Build Lighthouse
job it will checkout the code, run the test and then trigger a deployment. Once
deployed the acceptance tests will run to see whether the deployment was
successful.

[dstl-lighthouse-secrets]:https://github.com/livestax/dstl-lighthouse-secrets

## Debugging

**Web logs - what traffic hit and errors occurred? **

- /var/log/nginx/error.log and /var/log/nginx/access.log
- /etc/uwsgi/vassals/lighthouse.ini
- /etc/uwsgi/emperor.ini
- /var/log/uwsgi/lighthouse.log
- curl localhost:8080/login - to see whether we get back html.

**These will tell you whether lighthouse came up or not**

- sudo systemctl status emperor
- sudo journalctl -xe -u emperor
