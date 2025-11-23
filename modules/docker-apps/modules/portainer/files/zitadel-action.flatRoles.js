/**
 * Sets the `roles` claim in the token with `project:role` values.
 * 
 * The `roles` claims of the token look like the following:
 * 
 * // added by the code below
 * "roles": ["{projectId}:{roleName}", "{projectId}:{roleName}", ...]
 *
 * Flow: Complement token, Triggers: Pre Userinfo creation, Pre access token creation
 *
 * @param ctx
 * @param api
 */
let logger = require('zitadel/log');
function flatRoles(ctx, api) {
    const userGrants = ctx.v1.user?.grants?.grants;

    if (userGrants == undefined || ctx.v1.user.grants.count == 0) {
        log.warn(`[flatRoles] Could not add flattened roles for user '${ctx.v1.user.username}'!`);
        return;
    }

    let roles = [];
    userGrants.forEach(claim => {
        claim.roles.forEach(role => {
            roles.push(role)
        })
    })

    if (roles.length > 0) {
        api.v1.claims.setClaim('roles', roles)
    } else {
        log.warn(`[flatRoles] User '${ctx.v1.user.username}' did not have any roles.`);
    }
}