
public class Usuario {

    private int idUsuario;
    private int idRol;
    private String nombre;
    private String rol;

    public Usuario(String nombre, String rol, int idRol, int idUsuario) {
        this.nombre = nombre;
        this.rol = rol;
        this.idRol = idRol;
        this.idUsuario = idUsuario;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public String getRol() {
        return rol;
    }

    public int getIdRol() {
        return idRol;
    }
}
