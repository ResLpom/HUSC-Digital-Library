package vn.edu.husc.library.util;

import java.io.File;

public class ExamStorageConfig {

    public static final String ROOT_PATH = "D:/upLoad";

    public static final String TYPE_DE_CUONG = "de-cuong";
    public static final String TYPE_NGAN_HANG_DE = "ngan-hang-de";

    private ExamStorageConfig() {
    }

    public static File getRootFolder(String type) {
        type = normalizeType(type);

        if (TYPE_DE_CUONG.equals(type)) {
            return new File(ROOT_PATH + "/de-cuong/exam-bank");
        }

        return new File(ROOT_PATH + "/ngan-hang-de/exam-bank");
    }

    public static String normalizeType(String type) {
        if (type == null) {
            return TYPE_NGAN_HANG_DE;
        }

        if (TYPE_DE_CUONG.equalsIgnoreCase(type)) {
            return TYPE_DE_CUONG;
        }

        if (TYPE_NGAN_HANG_DE.equalsIgnoreCase(type)) {
            return TYPE_NGAN_HANG_DE;
        }

        return TYPE_NGAN_HANG_DE;
    }

    public static String getTypeLabel(String type) {
        type = normalizeType(type);

        if (TYPE_DE_CUONG.equals(type)) {
            return "Đề cương";
        }

        return "Ngân hàng đề";
    }
}