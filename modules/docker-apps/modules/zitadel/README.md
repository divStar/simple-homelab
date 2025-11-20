# Zitadel

## Gotcha's

If Zitadel does not want to deploy, **look for the first error**, not the follow-up ones.

I have experienced Zitadel not starting up, because `/mnt/data/zitadel` belonged to **`root:root`** rather than **`1000:1000`**.
**Zitadel will only work if that folder belongs to the _latter_!**

Once Zitadel starts up, don't forget to copy the `admin_key.json` over from `/mnt/data/zitadel` to `../`. It is required in order to be able to create projects, applications, roles etc. using the official Zitadel Terraform provider.