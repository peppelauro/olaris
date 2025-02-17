#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
IP="$1"
# if not provided try to retrieve the public it
if test -z "$IP"
then IP="$(curl https://ipecho.net/plain)"
fi
if test -z "$IP"
then IP="$(curl ifconfig.me)"
fi
# install microk8s
apt-get update
apt-get install -y snapd curl grep sudo
snap install microk8s --classic
microk8s stop
sed -i "/#MOREIPS/a IP.10 = $IP" /var/snap/microk8s/current/certs/csr.conf.template
microk8s start
while microk8s kubectl get nodes | grep NotReady
do echo Waiting for Ready ; sleep 5
done
microk8s enable hostpath-storage dns ingress cert-manager
