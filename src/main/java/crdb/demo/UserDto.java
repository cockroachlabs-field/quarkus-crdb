package crdb.demo;
public class UserDto {
    private Long id;
    private String username;
    private String password;
    private String email;
 
    public void setPassword(String password) {
        this.password = password;
    } 
 
    //@JsonIgnore
    public String getPassword() {
        return this.password;
    }

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}
 
}
