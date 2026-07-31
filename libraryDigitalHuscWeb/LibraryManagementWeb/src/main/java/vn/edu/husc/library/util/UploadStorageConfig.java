package vn.edu.husc.library.util;

import java.io.File;

public class UploadStorageConfig {

    public static final String ROOT_PATH = "D:/upLoad";

    public static final String DOCUMENT_IMAGE_FOLDER = ROOT_PATH + "/document";
    public static final String EQUIPMENT_IMAGE_FOLDER = ROOT_PATH + "/equipment";

    private UploadStorageConfig() {
    }

    public static File getDocumentImageFolder() {
        File folder = new File(DOCUMENT_IMAGE_FOLDER);

        if (!folder.exists()) {
            folder.mkdirs();
        }

        return folder;
    }

    public static File getEquipmentImageFolder() {
        File folder = new File(EQUIPMENT_IMAGE_FOLDER);

        if (!folder.exists()) {
            folder.mkdirs();
        }

        return folder;
    }

    public static File getFolderByType(String type) {
        if (type == null) {
            return null;
        }

        if ("document".equalsIgnoreCase(type)
                || "documents".equalsIgnoreCase(type)) {
            return getDocumentImageFolder();
        }

        if ("equipment".equalsIgnoreCase(type)
                || "equipments".equalsIgnoreCase(type)) {
            return getEquipmentImageFolder();
        }

        return null;
    }
}