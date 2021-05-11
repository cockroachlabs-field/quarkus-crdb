package crdb.demo;
import org.mapstruct.Mapper;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import io.quarkus.hibernate.orm.panache.PanacheQuery;

@Mapper(componentModel = "cdi")
public interface UserMapper {
    UserDto toResource(PanacheQuery<PanacheEntityBase> u);
    User fromResource(UserDto userDto);
}
