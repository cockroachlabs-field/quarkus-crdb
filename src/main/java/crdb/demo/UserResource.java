package crdb.demo;
import java.util.Optional;

import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Response;

@Path("/users")
@Produces("application/json")
@Consumes("application/json")
public class UserResource {

	@Inject
	UserMapper userMapper;
	 
	@Transactional
	@POST
	public Response create(UserDto userDto) {
	    User user = userMapper.fromResource(userDto);
	    user.persistAndFlush();
	    //return Response.ok(userMapper.toResource(user)).build();
	    return Response.ok().build();
	}
	
	@GET
	@Path("/{username}")
	public Response find(@PathParam("username") String username) {
	    return Optional.ofNullable(User.find("username", username))
	            .map(u -> Response.ok(userMapper.toResource(u)))
	            .orElseGet(() -> Response.status(Response.Status.NOT_FOUND))
	            .build();
	}
}