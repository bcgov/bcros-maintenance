**Role SRE**

 *generate-sre-role.sh* script generates role for SRE team member via taking a union of all enabled APIs across BC Registries GCP projects minus the excluded APIs and permissions.

Current role definition generated via the script is commited to the repo to track changes.

As of writing, GCP does not allow custom roles with more than 3000 permissions or permissions files larger than 64KB. In addition, some permissions cannot be assigned to custom roles. Every attempt is made to make SRE role mimic project owner role within that constraint.
